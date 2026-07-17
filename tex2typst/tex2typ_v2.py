#!/usr/bin/env python3
"""
tex2typ_v2.py — Convert terrainbook LaTeX chapters to Typst.

Strategy: v1's direct regex-based conversion for environments/tags/headings/lists,
with t2l (tylax) used as the math engine to convert LaTeX math → Typst math.

Math blocks ($...$, \[...\], \begin{equation}...\end{equation}, etc.) are
preprocessed with t2l before the rest of the pipeline runs.

Usage:
    python convert/tex2typ_v2.py chapters/whatisterrain/whatisterrain.tex
"""

import re
import sys
import subprocess
from pathlib import Path
from typing import Callable


# ---------------------------------------------------------------------------
# Unit map for siunitx -> unify
# ---------------------------------------------------------------------------
UNIT_MAP = {
    r"\m": "m",
    r"\metre": "m",
    r"\meter": "m",
    r"\km": "km",
    r"\cm": "cm",
    r"\mm": "mm",
    r"\degree": "degree",
    r"\percent": "percent",
    r"\s": "s",
    r"\second": "s",
    r"\hour": "h",
    r"\h": "h",
    r"\Hz": "Hz",
    r"\MW": "MW",
    r"\GW": "GW",
    r"\W": "W",
    r"\kW": "kW",
    r"\N": "N",
    r"\Pa": "Pa",
    r"\kPa": "kPa",
    r"\MPa": "MPa",
    r"\GPa": "GPa",
    r"\J": "J",
    r"\kJ": "kJ",
    r"\MJ": "MJ",
    r"\g": "g",
    r"\kg": "kg",
    r"\mg": "mg",
    r"\t": "t",
    r"\ton": "t",
    r"\L": "L",
    r"\mL": "mL",
    r"\ha": "ha",
    r"\mol": "mol",
    r"\mmol": "mmol",
    r"\V": "V",
    r"\kV": "kV",
    r"\A": "A",
    r"\mA": "mA",
    r"\ohm": "ohm",
    r"\kohm": "kohm",
    r"\Mohm": "Mohm",
    r"\cd": "cd",
    r"\lm": "lm",
    r"\lx": "lx",
    r"\Bq": "Bq",
    r"\Gy": "Gy",
    r"\Sv": "Sv",
    r"\kat": "kat",
    r"\rad": "rad",
    r"\sr": "sr",
}


# ---------------------------------------------------------------------------
# Placeholder machinery
# ---------------------------------------------------------------------------
class PlaceholderStore:
    def __init__(self):
        self.store = {}
        self.counter = 0

    def add(self, text: str) -> str:
        self.counter += 1
        key = f"TYPSTPLACEHOLDER{self.counter:04d}"
        self.store[key] = text
        return key

    def restore(self, text: str) -> str:
        for key, val in self.store.items():
            text = text.replace(key, val)
        return text


# ---------------------------------------------------------------------------
# t2l math conversion
# ---------------------------------------------------------------------------
def convert_math_block_via_t2l(latex_str: str) -> str:
    """Convert a LaTeX math expression/block to Typst using t2l (tylax).

    The input can be a raw math expression, an inline $...$ block,
    or a full \\begin{equation}...\\end{equation} environment.
    t2l produces Typst math output.
    """
    result = subprocess.run(
        ["t2l", "-d", "l2t", "--no-preamble"],
        input=latex_str,
        capture_output=True,
        text=True,
    )
    out = result.stdout.strip()
    # t2l splits "bb(R)" into "b b(R)" (treats bb as b*b); restore it
    out = re.sub(r'\bb\s+b\(', 'bb(', out)
    # t2l produces "tau _(big)" for multi-letter subscripts, but Typst
    # requires quotes around multi-character identifiers: "tau _\"big\""
    # t2l may insert a space before "_(...)" for multi-letter bases (e.g. Greek)
    out = re.sub(r'\s*_\(([A-Za-z]{2,})\)', lambda m: '_"' + m.group(1) + '"', out)
    # Clean up unnecessary parentheses/whitespace for single-letter/digit subscripts
    out = re.sub(r'\s*_\((\w)\)', r'_\1', out)
    return out


# ---------------------------------------------------------------------------
# Image helpers
# ---------------------------------------------------------------------------
KNOWN_IMG_EXTS = ('.pdf', '.png', '.jpg', '.jpeg', '.svg')


def resolve_image_ext(img_path: str, chapter_dir: Path) -> str:
    """Ensure img_path has a valid extension.

    If img_path already has a recognised extension, return as-is.
    Otherwise look in chapter_dir/figs/ for a matching file and add the
    correct extension.  Falls back to .pdf if nothing is found.
    """
    if any(img_path.endswith(ext) for ext in KNOWN_IMG_EXTS):
        return img_path

    # Try the figs/ subdirectory of the chapter
    figs_dir = chapter_dir / 'figs'
    if figs_dir.is_dir():
        stem = Path(img_path).stem
        for ext in KNOWN_IMG_EXTS:
            candidate = figs_dir / (stem + ext)
            if candidate.is_file():
                # Rebuild relative path with the found extension
                parent = Path(img_path).parent
                return str(parent / (stem + ext))

    return img_path + '.pdf'


# ---------------------------------------------------------------------------
# Inline helpers
# ---------------------------------------------------------------------------
def escape_for_replacement(s: str) -> str:
    # Double backslashes for regex replacement string
    return s.replace("\\", "\\\\")


def safe_extract_caption(text: str) -> str:
    r"""Extract \caption{...} handling math sub-expressions that contain braces."""
    math_placeholders = {}
    counter = [0]
    def math_repl(m):
        key = f'MATHPLACEHOLDER{counter[0]}'
        counter[0] += 1
        math_placeholders[key] = m.group(0)
        return key
    text = re.sub(r'\$[^$]+\$', math_repl, text)
    cap_match = re.search(r'\\caption\{([^{}]*(?:\{[^}]*\}[^{}]*)*)\}', text, re.DOTALL)
    if cap_match:
        caption = cap_match.group(1)
        for key, val in math_placeholders.items():
            caption = caption.replace(key, val)
        return caption
    return ""


def clean_caption(s: str) -> str:
    s = re.sub(r'%\s*$', '', s, flags=re.MULTILINE)
    s = re.sub(r'\s+', ' ', s)
    s = re.sub(r'\\textbf\{([^}]+)\}', r'#strong[\1]', s)
    s = re.sub(r'\\emph\{([^}]+)\}', r'#emph[\1]', s)
    s = re.sub(r'\\citet\{([^}]+)\}', r'#citet(<\1>)', s)
    s = re.sub(r'\\citep\{([^}]+)\}', r'#citep(<\1>)', s)
    s = re.sub(r'\\url\{([^}]+)\}', r'link("\1")', s)
    s = re.sub(r'\\eg\s*', 'eg ', s)
    s = re.sub(r'\\ie\s*', 'ie ', s)
    s = re.sub(r'\\ldots', '...', s)
    s = re.sub(r'\\@', '', s)
    s = re.sub(r'~', ' ', s)
    s = re.sub(r'\\qty\{([^}]+)\}\{([^}]+)\}', lambda m: f'#qty("{m.group(1)}", "{UNIT_MAP.get(m.group(2), m.group(2))}")', s)
    # LaTeX double backtick quotes: ``word'' -> "word" (must run first)
    s = re.sub(r"``(.+?)''", r'"\1"', s)
    # LaTeX single backtick quotes: `word' -> 'word'
    s = re.sub(r"`([^']+)'", r"'\1'", s)
    return s.strip()


def clean_inline(s: str) -> str:
    s = re.sub(r'\\emph\{([^}]+)\}', r'_\1_', s)
    s = re.sub(r'\\textbf\{([^}]+)\}', r'*\1*', s)
    s = re.sub(r'\\texttt\{([^}]+)\}', r'`\1`', s)
    s = re.sub(r'\\url\{([^}]+)\}', r'link("\1")', s)
    s = re.sub(r'\\eg\s*', 'eg ', s)
    s = re.sub(r'\\ie\s*', 'ie ', s)
    s = re.sub(r'\\ldots', '...', s)
    s = re.sub(r'\\@', '', s)
    s = re.sub(r'~\s*', ' ', s)
    # siunitx inline
    s = re.sub(r'\\qty\{([^}]+)\}\{([^}]+)\}', lambda m: f'#qty("{m.group(1)}", "{UNIT_MAP.get(m.group(2), m.group(2))}")', s)
    # Index -> keep as index
    s = re.sub(r'\\index\{([^}]+)\}', r'#index[\1]', s)
    # Marginnote -> note
    s = re.sub(r'\\marginnote\[[^\]]*\]\{([^}]+)\}', r'#note[\1]', s)
    s = re.sub(r'\\marginnote\{([^}]+)\}', r'#note[\1]', s)
    # Citations
    s = re.sub(r'\\citet\{([^},]+)\}', r'#citet(<\1>)', s)
    s = re.sub(r'\\citep\{([^},]+)\}', r'#citep(<\1>)', s)
    # Multi-key citations
    def multi_citet(m):
        keys = [k.strip() for k in m.group(1).split(',')]
        return r'/* TODO: split \citet{' + ','.join(keys) + '} */ ' + ' '.join(f'#citet(<{k}>)' for k in keys)
    def multi_citep(m):
        keys = [k.strip() for k in m.group(1).split(',')]
        return r'/* TODO: split \citep{' + ','.join(keys) + '} */ ' + ' '.join(f'#citep(<{k}>)' for k in keys)
    s = re.sub(r'\\citet\{([^}]+,[^}]+)\}', multi_citet, s)
    s = re.sub(r'\\citep\{([^}]+,[^}]+)\}', multi_citep, s)
    # Cross-refs
    s = re.sub(r'Chapter~\\ref\{([^}]+)\}', r'Chapter @\1', s)
    s = re.sub(r'Section~\\ref\{([^}]+)\}', r'Section @\1', s)
    s = re.sub(r'Figure~\\ref\{([^}]+)\}', r'Figure @\1', s)
    s = re.sub(r'Algorithm~\\ref\{([^}]+)\}', r'Algorithm @\1', s)
    s = re.sub(r'Appendix~\\ref\{([^}]+)\}', r'Appendix @\1', s)
    s = re.sub(r'\\ref\{([^}]+)\}', r'@\1', s)
    # Typst auto-adds the "Figure" supplement, so strip it to avoid
    # "Figure Figure 1" in the rendered output.
    s = re.sub(r'Figure\s+@', '@', s)
    # Text-mode LaTeX markup
    s = re.sub(r'\\textrm\{([A-Za-z])\}\\textsc\{([A-Za-z]+)\}', r'"\1\2"', s)
    s = re.sub(r'\\textsc\{([A-Za-z]+)\}', r'"\1"', s)
    # LaTeX double backtick quotes: ``word'' -> "word" (must run first)
    s = re.sub(r"``(.+?)''", r'"\1"', s)
    # LaTeX single backtick quotes: `word' -> 'word'
    s = re.sub(r"`([^']+)'", r"'\1'", s)
    # Fix single-letter bold/italic mid-word: Typst *x* requires word boundaries
    s = re.sub(r'\*(\w)\*(?=\w)', r'#strong[\1]', s)
    s = re.sub(r'_(\w)_(?=\w)', r'#emph[\1]', s)
    # Remove LaTeX inline comments (% ...)
    s = re.sub(r'\s*%\s.*$', '', s)
    # Remove stray backslash-space macros
    s = re.sub(r'\\ ', ' ', s)
    # Clean up multiple spaces
    s = re.sub(r' +', ' ', s)
    return s


# ---------------------------------------------------------------------------
# Math preprocessing: LaTeX math -> Typst math via t2l
# ---------------------------------------------------------------------------
def preprocess_math(tex: str) -> str:
    """Convert all LaTeX math to Typst in-place.

    Uses a local placeholder store: display math is extracted first so the
    subsequent inline $...$ regex does not re-match already-converted blocks.
    All placeholders are restored before returning, so downstream pipeline
    sees clean Typst math.
    """
    store = PlaceholderStore()

    # Normalise \circ to \degree (t2l garbles \circ into circle.small)
    tex = re.sub(r'\\circ(?:\{\})?', r'\\degree', tex)
    # Normalise \mathbb{X} → bb(X) (t2l converts to double-struck "RR" etc;
    # we prefer the function-call form so it survives t2l unchanged)
    tex = re.sub(r'\\mathbb\{([A-Za-z0-9])\}', r'bb(\1)', tex)

    # 1. Display math environments — pass the full environment to t2l so it
    #    can extract labels, wrap in $...$, etc. correctly
    display_envs = [
        r'equation\*?',
        r'align\*?',
        r'gather\*?',
        r'alignat\*?',
    ]
    for env_name in display_envs:
        pattern = re.compile(
            r'\\begin\{' + env_name + r'\}\s*(.*?)\\end\{' + env_name + r'\}',
            re.DOTALL,
        )
        tex = pattern.sub(lambda m: store.add(convert_math_block_via_t2l(m.group(0))), tex)

    # 2. \[ ... \] display math
    tex = re.sub(
        r'\\\[\s*(.*?)\\\]',
        lambda m: store.add(convert_math_block_via_t2l(m.group(0))),
        tex,
        flags=re.DOTALL,
    )

    # 3. $$...$$ display math
    tex = re.sub(
        r'\$\$(.+?)\$\$',
        lambda m: store.add(convert_math_block_via_t2l(m.group(0))),
        tex,
        flags=re.DOTALL,
    )

    # 4. Inline $...$ (single $, not part of $$...$$)
    #    Safe now — display math was already extracted to placeholders above.
    def inline_dollar_repl(m):
        body = convert_math_block_via_t2l(m.group(1))
        if body.startswith('^') or body.startswith('_'):
            body = '{}' + body
        return store.add('$' + body + '$')
    tex = re.sub(
        r'(?<!\$)\$(?!\$)(.+?)(?<!\$)\$(?!\$)',
        inline_dollar_repl,
        tex,
        flags=re.DOTALL,
    )

    # 5. \(...\) inline math
    def inline_paren_repl(m):
        body = convert_math_block_via_t2l(m.group(1))
        if body.startswith('^') or body.startswith('_'):
            body = '{}' + body
        return store.add('$' + body + '$')
    tex = re.sub(
        r'\\\((.+?)\\\)',
        inline_paren_repl,
        tex,
        flags=re.DOTALL,
    )

    # Restore all math placeholders immediately so downstream pipeline
    # (environment extraction, clean_inline, etc.) sees clean Typst math.
    return store.restore(tex)


# ---------------------------------------------------------------------------
# Environment extractors
# ---------------------------------------------------------------------------
def extract_environment(tex: str, env_name: str) -> list:
    """Return list of (full_match, inner_body) for a LaTeX environment."""
    pattern = re.compile(
        r'\\begin\{' + re.escape(env_name) + r'\}(?:\[[^\]]*\])?\s*'
        r'(?P<body>.*?)'
        r'\\end\{' + re.escape(env_name) + r'\}',
        re.DOTALL,
    )
    return [(m.group(0), m.group('body')) for m in pattern.finditer(tex)]


def replace_environment(tex: str, env_name: str, replacer: Callable, store: PlaceholderStore) -> str:
    """Extract environment, run replacer(inner_body) -> typst string, store in placeholder."""
    pattern = re.compile(
        r'\\begin\{' + re.escape(env_name) + r'\}(?:\[[^\]]*\])?\s*'
        r'(?P<body>.*?)'
        r'\\end\{' + re.escape(env_name) + r'\}',
        re.DOTALL,
    )

    def subfn(m):
        inner = m.group('body')
        typ = replacer(inner)
        key = store.add(typ)
        return key

    return pattern.sub(subfn, tex)


# ---------------------------------------------------------------------------
# Environment replacers
# ---------------------------------------------------------------------------
def _parse_includegraphics(match, chapter_dir: Path):
    """Return (resolved_path, width_str, page_str) from an includegraphics match."""
    img = match.group(2)
    img = resolve_image_ext(img, chapter_dir)
    width = "100%"
    page = ""
    opts = match.group(1) or ""
    if opts:
        tw = re.search(r'width=([0-9.]+)?\\?(?:textwidth|linewidth)', opts)
        if tw:
            factor = tw.group(1)
            if factor:
                width = str(int(float(factor) * 100)) + '%'
            else:
                width = "100%"
        else:
            w = re.search(r'width=([0-9.]+\\?[a-z]+|\\[a-z]+)', opts)
            if w:
                wval = w.group(1)
                if wval.startswith('\\'):
                    wval = wval[1:]
                width = wval
        p = re.search(r'page=(\d+)', opts)
        if p:
            page = f', page: {p.group(1)}'
    return img, width, page


def make_marginfigure_replacer(tex_src: str, chapter_dir: Path):
    def replacer(inner: str) -> str:
        img_matches = list(re.finditer(r'\\includegraphics(?:\[([^\]]*)\])?\{([^}]+)\}', inner))
        caption = safe_extract_caption(inner)
        caption = clean_caption(caption)
        lbl_match = re.search(r'\\label\{([^}]+)\}', inner)
        label = f" <{lbl_match.group(1)}>" if lbl_match else ""

        if len(img_matches) == 1:
            img, width, page = _parse_includegraphics(img_matches[0], chapter_dir)
            return f'#notefigure(\n  image("{img}", width: {width}{page}),\n  caption: [{caption}],\n){label}'
        elif len(img_matches) > 1:
            lines = []
            for m in img_matches:
                img, width, page = _parse_includegraphics(m, chapter_dir)
                lines.append(f'  image("{img}", width: {width}{page})')
            return f'#notefigure(\n' + ',\n'.join(lines) + f',\n  caption: [{caption}],\n){label}'
        else:
            return f'/* TODO: marginfigure without image */'
    return replacer


def make_figure_replacer(tex_src: str, store: PlaceholderStore, chapter_dir: Path):
    def replacer(inner: str) -> str:
        # Check for subfigures first
        if '\\begin{subfigure}' in inner:
            return handle_subfigures(inner, store, chapter_dir)
        # Check for minipage/tabular
        if '\\begin{minipage}' in inner or '\\begin{tabular}' in inner:
            return f'/* TODO: figure with minipage/table */\n/*\n{inner.strip()}\n*/'
        # Check for algorithm
        if '\\begin{algorithm}' in inner:
            return f'/* TODO: algorithm inside figure */\n/*\n{inner.strip()}\n*/'

        img_matches = list(re.finditer(r'\\includegraphics(?:\[([^\]]*)\])?\{([^}]+)\}', inner))
        caption = safe_extract_caption(inner)
        caption = clean_caption(caption)
        lbl_match = re.search(r'\\label\{([^}]+)\}', inner)
        label = f" <{lbl_match.group(1)}>" if lbl_match else ""
        placement = "auto" if 'figure*' in inner[:30] else "none"

        if len(img_matches) == 1:
            img, width, page = _parse_includegraphics(img_matches[0], chapter_dir)
            return f'#figure(\n  image("{img}", width: {width}{page}),\n  caption: [{caption}],\n  placement: {placement},\n){label}'
        elif len(img_matches) > 1:
            lines = []
            for m in img_matches:
                img, width, page = _parse_includegraphics(m, chapter_dir)
                lines.append(f'  image("{img}", width: {width}{page})')
            return f'#figure(\n' + ',\n'.join(lines) + f',\n  caption: [{caption}],\n  placement: {placement},\n){label}'
        else:
            return f'/* TODO: figure without image */\n#figure(\n  /* TODO */\n  caption: [{caption}],\n  placement: {placement},\n){label}'
    return replacer


def handle_subfigures(inner: str, store: PlaceholderStore, chapter_dir: Path) -> str:
    # Find outer caption by stripping subfigure blocks
    outer_text = re.sub(
        r'\\begin\{subfigure\}(?:\[[^\]]*\])?\{(?:[^}]+)\}\s*'
        r'.*?'
        r'\\end\{subfigure\}',
        '',
        inner,
        flags=re.DOTALL,
    )
    caption = safe_extract_caption(outer_text)
    caption = clean_caption(caption)
    lbl_match = re.search(r'\\label\{([^}]+)\}', inner)
    label = f" <{lbl_match.group(1)}>" if lbl_match else ""
    placement = "auto" if 'figure*' in inner[:30] else "none"

    subfigs = []
    for sm in re.finditer(
        r'\\begin\{subfigure\}(?:\[[^\]]*\])?\{(?:[^}]+)\}\s*'
        r'(?:\\centering\s*)?'
        r'\\includegraphics(?:\[[^\]]*\])?\{([^}]+)\}\s*'
        r'(?:\\caption\{([^}]*)\})?'
        r'(?:\s*\\label\{([^}]+)\})?',
        inner,
        re.DOTALL,
    ):
        img = sm.group(1)
        subcap = clean_caption(sm.group(2)) if sm.group(2) else ""
        sublbl = sm.group(3) if sm.group(3) else ""
        img = resolve_image_ext(img, chapter_dir)
        subfig_block = sm.group(0)
        opts_match = re.search(r'\\includegraphics\[([^\]]*)\]\{' + re.escape(sm.group(1)) + r'\}', subfig_block)
        page = ""
        if opts_match:
            p = re.search(r'page=(\d+)', opts_match.group(1))
            if p:
                page = f', page: {p.group(1)}'
        subfigs.append((img, subcap, sublbl, page))

    if len(subfigs) in (2, 4):
        columns = '(1fr, 1fr)'
    elif len(subfigs) == 3:
        columns = '(1fr, 1fr, 1fr)'
    else:
        columns = '(1fr,)'

    figure_lines = []
    for img, subcap, sublbl, page in subfigs:
        ref = f', <{sublbl}>' if sublbl else ''
        figure_lines.append(f'  figure(image("{img}", width: 100%{page}), caption: [{subcap}]){ref},')

    return (
        f'/* TODO: verify subfigure layout */\n'
        f'#subfigure(\n'
        f'{chr(10).join(figure_lines)}\n'
        f'  columns: {columns},\n'
        f'  caption: [{caption}],\n'
        f'  placement: {placement},\n'
        f'  label: {label.strip() if label else "<fig:sub>"},\n'
        f')'
    )


def make_algorithm_replacer(tex_src: str):
    def replacer(inner: str) -> str:
        return '/* TODO: convert algorithm to lovelace pseudocode-list */\n/*\n\\begin{{algorithm}}' + inner + '\\end{{algorithm}}\n*/'
    return replacer


def make_kaobox_replacer(tex_src: str):
    def replacer(inner: str) -> str:
        # inner starts with \begin{kaobox-practice}[...] or similar
        ft_match = re.search(r'\\begin\{kaobox-practice\}\[(?:.*?)frametitle=(.+?)\]', inner, re.DOTALL)
        if ft_match:
            title = ft_match.group(1).strip()
            title = re.sub(r'\\faCog\s*', '\u2699\uFE0F ', title)
            title = re.sub(r'\\url\{([^}]+)\}', r'\1', title)
        else:
            title = "Practice box"
        # Remove the \begin{...}...[...] line from inner
        body = re.sub(r'\\begin\{kaobox-practice\}(?:\[[^\]]*\])?\s*', '', inner, count=1)
        body = re.sub(r'\\end\{kaobox-practice\}\s*', '', body, count=1)
        body = body.strip()
        body = clean_inline(body)
        return f'#box-practice("{title}")[{body}]'
    return replacer


def make_floatbox_replacer(tex_src: str, store: PlaceholderStore):
    def replacer(inner: str) -> str:
        # Extract kaobox-practice inside
        kb_match = re.search(
            r'\\begin\{kaobox-practice\}(?:\[[^\]]*\])?\s*'
            r'(?P<body>.*?)'
            r'\\end\{kaobox-practice\}',
            inner,
            re.DOTALL,
        )
        if kb_match:
            ft_match = re.search(r'\\begin\{kaobox-practice\}\[(?:.*?)frametitle=(.+?)\]', inner, re.DOTALL)
            if ft_match:
                title = ft_match.group(1).strip()
                title = re.sub(r'\\faCog\s*', '\u2699\uFE0F ', title)
                title = re.sub(r'\\url\{([^}]+)\}', r'\1', title)
            else:
                title = "Practice box"
            body = kb_match.group('body').strip()
            body = clean_inline(body)
            return f'#box-practice("{title}")[{body}]'
        return f'/* TODO: floatbox without kaobox-practice */\n/*\n{inner.strip()}\n*/'
    return replacer


# ---------------------------------------------------------------------------
# List / quote / description / enumerate / itemize
# ---------------------------------------------------------------------------
def transform_lists(tex: str) -> str:
    # itemize -> - list
    def itemize_repl(m):
        body = m.group('body')
        items = re.findall(r'\\item\s+(.*?)(?=\\item|$)', body, re.DOTALL)
        lines = []
        for it in items:
            it = clean_inline(it.strip())
            lines.append(f'- {it}')
        return '\n'.join(lines)

    tex = re.sub(
        r'\\begin\{itemize\}\s*(?P<body>.*?)\\end\{itemize\}',
        itemize_repl,
        tex,
        flags=re.DOTALL,
    )

    # enumerate -> + list
    def enum_repl(m):
        body = m.group('body')
        items = re.findall(r'\\item\s+(.*?)(?=\\item|$)', body, re.DOTALL)
        lines = []
        for it in items:
            it = clean_inline(it.strip())
            lines.append(f'+ {it}')
        return '\n'.join(lines)

    tex = re.sub(
        r'\\begin\{enumerate\}\s*(?P<body>.*?)\\end\{enumerate\}',
        enum_repl,
        tex,
        flags=re.DOTALL,
    )

    # description -> / terms:
    def desc_repl(m):
        body = m.group('body')
        # Find all \item[TERM] ... (until next \item or end)
        items = re.findall(
            r'\\item\[([^\]]+)\]\s*(.*?)(?=\\item|$)',
            body,
            re.DOTALL,
        )
        lines = []
        for term, it in items:
            term = clean_inline(term.strip())
            it = clean_inline(it.strip())
            lines.append(f'/ {term}: {it}')
        return '\n'.join(lines)

    tex = re.sub(
        r'\\begin\{description\}\s*(?P<body>.*?)\\end\{description\}',
        desc_repl,
        tex,
        flags=re.DOTALL,
    )

    # quote
    def quote_repl(m):
        body = m.group('body').strip()
        body = clean_inline(body)
        return f'#quote(block: true)[\n{body}\n]'

    tex = re.sub(
        r'\\begin\{quote\}\s*(?P<body>.*?)\\end\{quote\}',
        quote_repl,
        tex,
        flags=re.DOTALL,
    )

    return tex


# ---------------------------------------------------------------------------
# Headings
# ---------------------------------------------------------------------------
def transform_headings(tex: str) -> str:
    # \chapter{...}\label{...}
    def chapter_repl(m):
        title = m.group(1).strip()
        label = m.group(2) if m.group(2) else ""
        out = f'= {title}'
        if label:
            out += f' <{label}>'
        out += '\n\n'
        out += '#minitoc(suboutline(depth: 1, indent: 0pt))\n\n'
        return out

    tex = re.sub(
        r'\\chapter\{([^}]+)\}\s*(?:\\label\{([^}]+)\}\s*)?',
        chapter_repl,
        tex,
    )

    # \section[short]{long}[header]
    def section_repl(m):
        short = m.group(1)
        long = m.group(2)
        header = m.group(3)
        label = m.group(4) if m.group(4) else ""
        title = long.strip()
        if short and short.strip():
            title = f'#flex-heading[{short.strip()}][{long.strip()}]'
        out = f'== {title}'
        if label:
            out += f' <{label}>'
        return '\n' + out + '\n\n'

    tex = re.sub(
        r'\\section\[([^\]]*)\]\{([^}]+)\}(?:\[([^\]]*)\])?\s*(?:\\label\{([^}]+)\}\s*)?',
        section_repl,
        tex,
    )
    # plain \section{...} with optional label
    def plain_section_repl(m):
        title = m.group(1).strip()
        label = m.group(2) if m.group(2) else ""
        out = f'== {title}'
        if label:
            out += f' <{label}>'
        return '\n' + out + '\n\n'
    # \section{long}[short]  (must run before plain \section{...})
    def section_short_after_repl(m):
        long = m.group(1)
        short = m.group(2)
        label = m.group(3) if m.group(3) else ""
        title = long.strip()
        if short and short.strip():
            title = f'#flex-heading[{short.strip()}][{long.strip()}]'
        out = f'== {title}'
        if label:
            out += f' <{label}>'
        return '\n' + out + '\n\n'
    tex = re.sub(
        r'\\section\{([^}]+)\}\[([^\]]*)\]\s*(?:\\label\{([^}]+)\}\s*)?',
        section_short_after_repl,
        tex,
    )
    # plain \section{...} with optional label
    tex = re.sub(
        r'\\section\{([^}]+)\}\s*(?:\\label\{([^}]+)\}\s*)?',
        plain_section_repl,
        tex,
    )

    # \subsection{...}
    def subsection_repl(m):
        short = m.group(1) if m.group(1) else ""
        long = m.group(2)
        label = m.group(3) if m.group(3) else ""
        title = long.strip()
        if short and short.strip():
            title = f'#flex-heading[{short.strip()}][{long.strip()}]'
        out = f'=== {title}'
        if label:
            out += f' <{label}>'
        return '\n' + out + '\n\n'
    tex = re.sub(
        r'\\subsection\[([^\]]*)\]\{([^}]+)\}\s*(?:\\label\{([^}]+)\}\s*)?',
        subsection_repl,
        tex,
    )
    # plain \subsection{...}
    def plain_sub_repl(m):
        title = m.group(1).strip()
        label = m.group(2) if m.group(2) else ""
        out = f'=== {title}'
        if label:
            out += f' <{label}>'
        return '\n' + out + '\n\n'
    tex = re.sub(
        r'\\subsection\{([^}]+)\}\s*(?:\\label\{([^}]+)\}\s*)?',
        plain_sub_repl,
        tex,
    )

    # \subsubsection{...}
    tex = re.sub(
        r'\\subsubsection\{([^}]+)\}\s*(?:\\label\{([^}]+)\}\s*)?',
        lambda m: '\n==== ' + m.group(1).strip() + (f' <{m.group(2)}>' if m.group(2) else '') + '\n\n',
        tex,
    )

    # \paragraph{...} / \paragraph*{...}
    tex = re.sub(
        r'\\paragraph\*?\{([^}]+)\}',
        lambda m: '\n==== ' + m.group(1).strip() + '\n\n',
        tex,
    )

    return tex


# ---------------------------------------------------------------------------
# Custom macros defined in the file
# ---------------------------------------------------------------------------
def expand_newcommands(tex: str) -> str:
    # Simple line-based: extract macro names, remove definitions, then mark usages as TODO
    back = chr(92)
    lines = tex.split(chr(10))
    names = []
    result = []
    for line in lines:
        stripped = line.strip()
        if stripped.startswith(back + 'newcommand{'):
            start = stripped.find(back + 'newcommand{') + len(back + 'newcommand{')
            end = stripped.find('}', start)
            if end > start:
                names.append(stripped[start:end])
            # Remove the definition line entirely (it will be gone from output)
            continue
        result.append(line)
    tex = chr(10).join(result)
    for name in names:
        tex = tex.replace(name, '/* TODO: ' + name + ' */')
    return tex


def strip_latex_metadata(tex: str) -> str:
    tex = re.sub(r'^\s*%\s*!TEX\s+root.*$', '', tex, flags=re.MULTILINE | re.IGNORECASE)
    tex = re.sub(r'^\s*%\s*chktex-file.*$', '', tex, flags=re.MULTILINE)
    tex = re.sub(r'\\graphicspath\{\{[^}]+\}\}\s*', '', tex)
    tex = re.sub(r'\\setchapterpreamble\[[^\]]*\]\{(?:[^{}]|\{[^}]*\})*\}\s*', '', tex)
    return tex


# ---------------------------------------------------------------------------
# Inline pass: paragraphs
# ---------------------------------------------------------------------------
def transform_paragraphs(tex: str) -> str:
    # Apply clean_inline line-by-line, preserving original line breaks.
    # Only skip lines that are already Typst blocks / headings / lists.
    lines = tex.split('\n')
    result = []

    for line in lines:
        stripped = line.strip()
        if not stripped:
            result.append('')
        elif stripped.startswith('#') or stripped.startswith('=') or stripped.startswith('/') or stripped.startswith('+') or stripped.startswith('-'):
            result.append(line)
        elif stripped.startswith('/*') or stripped.startswith('$'):
            result.append(line)
        elif line.startswith('  ') or line.startswith('\t'):
            result.append(line)
        elif re.match(r'^[\)\]\}\s,]+$', stripped):
            result.append(line)
        elif stripped.startswith('TYPSTPLACEHOLDER'):
            result.append(line)
        else:
            result.append(clean_inline(line))

    return '\n'.join(result)


# ---------------------------------------------------------------------------
# Main conversion
# ---------------------------------------------------------------------------
def convert_file(tex_path: Path) -> str:
    tex = tex_path.read_text()
    store = PlaceholderStore()

    # 0. Strip all LaTeX comments (% ...) so they don't interfere with regexes
    tex = re.sub(r'\s*%.*$', '', tex, flags=re.MULTILINE)
    # 1. Strip metadata
    tex = strip_latex_metadata(tex)

    # 2. Expand \newcommand macros
    tex = expand_newcommands(tex)

    # 3. Preprocess math with t2l (converts LaTeX math -> Typst math in-place)
    tex = preprocess_math(tex)

    # Directory of the chapter (for resolving image paths)
    chapter_dir = tex_path.parent

    # 4. Extract environments that pandoc would drop, and replace with placeholders
    # marginfigure
    tex = replace_environment(tex, 'marginfigure', make_marginfigure_replacer(tex, chapter_dir), store)
    # floatbox (contains kaobox-practice)
    tex = replace_environment(tex, 'floatbox', make_floatbox_replacer(tex, store), store)
    # algorithm
    tex = replace_environment(tex, 'algorithm', make_algorithm_replacer(tex), store)

    # 5. Extract standard figures (which may contain subfigures)
    figure_pattern = re.compile(
        r'\\begin\{(figure|figure\*)\}(?:\[[^\]]*\])?\s*'
        r'(?P<body>.*?)'
        r'\\end\{\1\}',
        re.DOTALL,
    )
    for m in figure_pattern.finditer(tex):
        full = m.group(0)
        inner = m.group('body')
        is_star = m.group(1).endswith('*')
        repl = make_figure_replacer(tex, store, chapter_dir)
        typ = repl(inner)
        key = store.add(typ)
        tex = tex.replace(full, key, 1)

    # 6. Lists / quotes
    tex = transform_lists(tex)

    # 7. Headings
    tex = transform_headings(tex)

    # 8. Clean up inline text in remaining paragraphs
    tex = transform_paragraphs(tex)

    # 9. Restore placeholders (environments + math)
    tex = store.restore(tex)

    # 10. Math spacing: consecutive lowercase letters in $...$ need spaces
    def math_spacing_repl(m):
        inner = m.group(1)
        if re.match(r'^[a-z]+$', inner) and len(inner) > 1:
            return '$' + ' '.join(inner) + '$'
        return m.group(0)
    tex = re.sub(r'\$([a-z]{2,})\$', math_spacing_repl, tex)

    # 11. Final cleanup: never more than one blank line
    tex = re.sub(r'\n{3,}', '\n\n', tex)
    tex = tex.strip()

    # 12. Header
    header = "#import \"../template.typ\": *\n\n"
    return header + tex + '\n'


def main() -> None:
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <path/to/chapter.tex>")
        sys.exit(1)

    tex_path = Path(sys.argv[1]).resolve()
    if not tex_path.exists():
        print(f"Error: {tex_path} not found.")
        sys.exit(1)

    typ_src = convert_file(tex_path)
    out_path = tex_path.with_suffix('.typ')
    out_path.write_text(typ_src)
    print(f"Wrote {out_path}")


if __name__ == '__main__':
    main()
