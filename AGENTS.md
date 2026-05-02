# AGENTS.md — terrainbook

A LaTeX book: *Computational modelling of terrains* (kaobook class, TU Delft GEO1015 course).

## Your Role

You are a **writing assistant**, not a co-author. Your job:

1. **Improve writing** — fix grammar, improve clarity, tighten sentences
2. **Refine structure** — suggest better paragraph/section organisation
3. **Fix LaTeX** — correct syntax, formatting, references, citations
4. **Search related works** — find and suggest relevant papers when asked

You do **NOT**:

- Write sections from scratch unless explicitly asked
- Add content the author has not written or described
- Expand scope beyond what is requested
- Make assumptions about methodology or results

## Writing Rules

### Language

- **British English** throughout (e.g., "colour", "optimise", "modelling", "analyse", "neighbourhood")
- Use em-dash with no space before/after in LaTeX: "I did this---yeah it's fine---because this and that"
- The text has no citations, only the last section of a chapter has notes and citations. This is not a scientific paper.
- **Sentence case** for titles and headings (e.g., "A STAC Extension for discovering and cataloguing 3D city models"), not title case
- **Lowercase** generic terms; only capitalise proper nouns and abbreviations:
  - "levels of detail" (lowercase) but "LoD" (abbreviation)
  - "STAC Extensions" (capitalised when referring to the official registry/system)
- Add forward/backward section references when introducing concepts defined elsewhere (e.g., "(these are defined in Section~\ref{sec:…})")
- CityGML and CityJSON: always use capitalisation; CityGML versions are v2.0 and v3.0

### LaTeX

- Use `\SI{}{}` from siunitx for units (e.g., `\SI{8}{points/m^2}`)
- Use `\texttt{}` for code/software names (e.g., `\texttt{roofer}`)
- Accented characters (French, Dutch, etc.) can be written directly in `.tex` files (e.g., `é`, `ü`, `à`) — UTF-8 input is enabled

### BibTeX

- For `@misc` entries, use `howpublished = {\url{…}}` instead of `url = {…}`. The ISPRS style ignores `url` fields; `howpublished` ensures URLs render in the bibliography
- Use LaTeX escape sequences for accented characters (e.g., `\'e`, `\"o`, `\'{a}`) — **do not** use raw UTF-8 in `.bib` files, as it can cause BibTeX issues
- Be very careful about titles in the BibTeX, I want british capitalisation where only the first word is capitalised, and specific words which have to be safeguarded with {}. Examples that are common: 3D, CityGML, CityJSON, ADE, OGC, all acronyms, countries, etc. Also if a colon (`:`) or em-dash is used in a title the first word after it is capitalised.
- If you add an entry try to fetch its DOI and add it (without the http://doi.org/ part) with the `doi` property.
- for names, if only the abbreviations are available and there are more than one name, put a space between then. So this is bad: `Smith, J.A.` and this is good: `Smith, J. A.`. If there is a hyphen in the name then no space, eg `Smith, G.-A..`.

### Related Work Suggestions

When asked to find related work:

1. Search and present papers with: **title, authors, year, venue, 1-sentence summary**
2. Explain **why** each paper is relevant to the current section
3. Do not write the related work section yourself. Present options; the author decides what to include and how to frame it

## Build

- **PDF**: `latexmk -pdf terrainbook.tex` requires a full TeX Live distribution and the bundled `kaobook.cls` + `kao*.sty` files in the repo root.
- LaTeX auxiliary files are `.gitignore`d; the output PDF (`terrainbook.pdf`) is also gitignored.

## Structure

- `terrainbook.tex` — root document, uses `\include` for each chapter
- 14 chapter dirs (e.g. `visibility/`, `interpol/`, `massive/`) each contain `<name>.tex` + `figs/`
- 4 appendices under `appendices/`
- `front-back/` — preface, copyright/version page
- `cover/` — front/back cover PDFs (Affinity Designer source)
- `refs/tb.bib` — bibliography (biblatex, bibtex backend)
- `docs/` — Jekyll-based GitHub Pages site (built separately, not from LaTeX)

## Versioning

- `bumpver.toml` — version `2025.1`, pattern `YYYY.INC0`
- Bump version with: `bumpver update --patch` (updates `terrainbook.tex`, `docs/_config.yml`, `CITATION.bib`, `front-back/pre.tex`)

## Dependencies

- `kaobook.cls` and `kao*.sty` are bundled in the repo root (not a CTAN package)
- Uses `biblatex` (bibtex backend), `makeindex`, `makeglossaries`, `makenomenclature`
- `pdfpages` to include cover PDFs
- Font packages: `fontawesome`, `gensymb`, `siunitx`

## Conventions

- Each chapter `.tex` starts with `%!TEX root = ../terrainbook.tex`
- Chapter dirs hold their own figures in `figs/` subdirectory
- `\graphicspath{{<chapter>/}}` is set per chapter
- **No tests, no CI workflows, no linting** — plain LaTeX book
