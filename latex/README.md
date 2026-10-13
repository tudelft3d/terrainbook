# LaTeX version of the book (legacy)

This folder holds the original LaTeX source of the book, kept as a reference during the transition to Typst.
The Typst source is the current one and leads; the LaTeX files are only consulted when an error has to be traced back to the original.

## Contents

- `terrainbook.tex` — the LaTeX root file (the equivalent of `terrainbook.typ` at the repository root)
- `kaobook.cls` and `kao*.sty` — the bundled *kaobook* class, which is not on CTAN

## Compiling

The root file is kept here, but it must be placed at the **repository root** to compile.
Every `\include`, `\includepdf` and `\bibliography` in it uses a path relative to the root, and the `kaobook` class files have to sit next to it:

```
cp latex/*.tex latex/*.cls latex/*.sty .
latexmk -pdf terrainbook.tex
```

Move (or copy) the files back to `latex/` afterwards, so that the repository root stays free of LaTeX auxiliary files.

Compiling requires a full TeX Live distribution, together with `biblatex` (bibtex backend), `makeindex`, `makeglossaries` and `makenomenclature`; the PDFs are `.gitignore`d.

## Each chapter folder

Every chapter folder still contains its original `.tex` file (e.g. `whatisterrain/whatisterrain.tex`), which is what each `.typ` file was generated from.
The conversion was done with `tex2typst/tex2typ_v2.py`:

```
python tex2typst/tex2typ_v2.py whatisterrain/whatisterrain.tex
```

The converter does not handle every construct (algorithms, subfigures, `minipage`/`tabular`, custom macros, etc. are left as `TODO` comments), so the `.tex` file is the reference to check against when something looks wrong in the Typst output.
Keep them until the conversion has been fully verified; they will eventually be deleted.
