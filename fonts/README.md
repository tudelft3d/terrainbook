# Bundled fonts

The book uses the [IBM Plex](https://github.com/IBM/plex) superfamily, bundled here so
that the PDF renders identically on every machine (macOS, Linux, CI).

| Slot | Family | File |
|------|--------|------|
| serif (body) | IBM Plex Serif | `IBMPlexSerif-{Regular,Italic,Bold,BoldItalic}.ttf` |
| serif (chapter number) | IBM Plex Serif SmBld | `IBMPlexSerif-SemiBold{Italic}.ttf` |
| sans (headings) | IBM Plex Sans | `IBMPlexSans-{Regular,Italic,Bold,BoldItalic}.ttf` |
| mono (code) | IBM Plex Mono | `IBMPlexMono-{Regular,Italic,Bold,BoldItalic}.ttf` |
| math | IBM Plex Math | `IBMPlexMath-Regular.ttf` |

## Versions

| Family | Version | Release |
|--------|---------|---------|
| IBM Plex Serif | 2.0.0 | `@ibm/plex-serif@2.0.0` |
| IBM Plex Sans | 1.1.0 | `@ibm/plex-sans@1.1.0` |
| IBM Plex Mono | 2.5.0 | `@ibm/plex-mono@2.5.0` |
| IBM Plex Math | 1.1.0 | `@ibm/plex-math@1.1.0` |

Downloaded from <https://github.com/IBM/plex/releases> (TTF, `fonts/complete/ttf/`).

## License

SIL Open Font License 1.1 — see `LICENSE-OFL.txt`.
Copyright © 2017 IBM Corp. with Reserved Font Name "Plex".

The OFL imposes no conditions on documents produced with the fonts, so the book
stays CC-BY-4.0; the only obligations are font-level (keep the license and the
reserved name). The fonts cannot be sold on their own.

## Build

Because the fonts are not installed system-wide, Typst must be pointed at this
directory:

```
typst compile --font-path fonts main.typ
```

or, once, for the shell session:

```
export TYPST_FONT_PATHS="$PWD/fonts"
typst compile main.typ
```

## Notes

- IBM Plex Serif ships a dedicated "Text" optical size (weight 450). It is not
  bundled because it has no bold companion in the same family; if wanted, add
  `IBMPlexSerif-Text{,Italic}.ttf` and use it for body text only.
- "IBM Plex Serif SmBld" is a separate family name (not a weight of
  "IBM Plex Serif") as far as Typst is concerned, so it is referenced explicitly
  in `template.typ`.
