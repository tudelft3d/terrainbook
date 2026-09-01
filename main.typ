// TODOs
// [ ] @app:ahn[Appendix]
// [ ] eg + ie
// [ ] https://github.com/typst/hayagriva/pull/484 school/institution not printed
// [ ] search in PDF for: "Target not found:"
// [x] references have DOIs: remove?
// [x] headers + page numbering at the bottom to fix
// [x] empty page at first have page numbering
// [x] harmonise Algorithms for...do etc
// [x] figure numbers in Appendices are back at 1.1...
// [x] table numbers are not reset at 1 each new chapter :\
// [x] index at the end has ugly large headers... remove



#import "template.typ": *

#show: doc => tbtemplate(
  version: "2026.0-beta3",
  cover: true,
  doc,
)



#front-matter[
  #include "front-back/pre.typ"
  #include "front-back/preface.typ"

  //-- outlines
  //-- remove the filling with dots for level=1
  #show outline.entry.where(level: 1): it => {
    show repeat: none
    it
  }

  #[
    #show outline.entry.where(
      level: 1,
    ): it => {
      v(22pt, weak: true)
      strong(it)
    }
    #outline(depth: 2, indent: auto)
  ]

  // // TODO: remove list of tables/algorithms
  // #outline(
  //   title: [List of tables],
  //   target: figure.where(kind: table),
  // )
  
  // #outline(
  //   title: [List of algorithms],
  //   target: figure.where(kind: "algorithm"),
  // )
]

//-- put in red chapter errors (instead of not being able to compile)
#let possible-missing-ref(it) = {
  if it.element != none {
    it
  } else {
    text(fill: red)[\<Target not found: #emph(str(it.target))\>]
  }
}
#show ref: possible-missing-ref


//-- main-matter
//-- break to an odd page before switching to main matter, so that any
//-- blank filler page stays unnumbered and chapter 1 starts at page 1
#set page(numbering: none)
#pagebreak(weak: true, to: "odd")
#main-matter[

  // #pagebreak()

  //-- main chapters
  #include "whatisterrain/whatisterrain.typ" //-- 01
  #include "acquisition/acquisition.typ"     //-- 02
  #include "gdem/gdem.typ"                   //-- 03
  #include "dtvd/dtvd.typ"                   //-- 04
  #include "interpol/interpol.typ"           //-- 05

  #include "kriging/kriging.typ"               //-- 06
  #include "conversion/conversion.typ"       //-- 07
  #include "topofeatures/topofeatures.typ"   //-- 08
  #include "visibility/visibility.typ"       //-- 09
  #include "runoff/runoff.typ"               //-- 10
  #include "pcprocessing/pcprocessing.typ"   //-- 11
  #include "massive/massive.typ"             //-- 12
  #include "spatialextent/spatialextent.typ" //-- 13
  #include "bathymetry/bathymetry.typ"       //-- 14

  //-- Appendices
  #set heading(numbering: "A.1")
  #set figure(numbering: dependent-numbering("A.1"))
  #counter(heading).update(0)
  #include "./appendices/pcformats/pcformats.typ"     //-- A
  #include "./appendices/ahn/ahn.typ"                 //-- B
  #include "./appendices/normalplane/normalplane.typ" //-- C
  #include "./appendices/equations/equations.typ"     //-- D

]


// #pagebreak()


#back-matter[
  //-- references
  #bibliography("./refs/tb.bib", style: "./refs/apa-annotated-bibliography_modified-HL.csl")

  = Index
  #columns(2)[
    #make-index(
      section-title: (letter, counter) => v(1.5em),
    )
  ]

  #pagebreak()

  #align(bottom)[
  This document was typeset using #link("https://typst.app")[Typst]\; its source code is freely available at #link("https://github.com/tudelft3d/terrainbook/").
    // TODO: colofon
    // The main font is Palatino.
    // The figures and diagrams were mostly drawn using IPE, PGF/Ti\emph{k}z and Omnigraffle.
  ]
]
