#import "template.typ": *

#show: doc => tbtemplate(
  version: "2026.0-beta2",
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
#pagebreak()
#pagebreak()
#main-matter[

  // = Testing 1 2 testing

  // #qty("0.7", "m")

  // #qty(92, "degree")
  // // #angle(92.0degree)
  
  // #qty(1, "arcsec")

  // #notefigure(
  //   grid(
  //     image("./dtvd/figs/local.pdf", width: 100%, page: 1),
  //     image("./dtvd/figs/local.pdf", width: 100%, page: 2),
  //   ),
  //   caption: [A quadrilateral that can be triangulated in two different ways. Only the top configuration is Delaunay. #strong[(top)] $sigma$ is locally Delaunay. #strong[(bottom)] $sigma$ is not locally Delaunay.],
  // ) 

  // #smallcaps[Orient]

  // #table(
  //   columns: 3,
  //   stroke: none,
  //   align: (left, center, left),
  //   table.header([DT], [], [VD]),
  //   table.hline(),
  //   [#text(color.rgb("#c9f6c8"))[*face*]], [#sym.arrow.l.r], [#text(color.rgb("#2e8b58"))[*vertex*]],
  //   [#text(color.rgb("#000080"))[*vertex*]], [#sym.arrow.l.r], [#text(color.rgb("#d6ecf3"))[*face*]],
  //   [#text(color.rgb("#e6793d"))[*edge*]], [#sym.arrow.l.r], [#text(color.rgb("#ffd602"))[*edge*]],
  //   table.hline(),
  // ),
  
  // #pagebreak()

  //-- main chapters
  #include "whatisterrain/whatisterrain.typ" //-- 01
  #include "acquisition/acquisition.typ"     //-- 02
  #include "gdem/gdem.typ"                   //-- 03
  #include "dtvd/dtvd.typ"                   //-- 04
  #include "interpol/interpol.typ"           //-- 05

  // #include "kriging/kriging.typ"             //-- 06
  #include "conversion/conversion.typ"       //-- 07
  // #include "topofeatures/topofeatures.typ"   //-- 08
  // #include "visibility/visibility.typ"       //-- 09
  // #include "runoff/runoff.typ"               //-- 10
  // #include "pcprocessing/pcprocessing.typ"   //-- 11
  // #include "massive/massive.typ"             //-- 12
  // #include "spatialextent/spatialextent.typ" //-- 13
  // #include "bathymetry/bathymetry.typ"       //-- .typ14

  //-- Appendices
  #set heading(numbering: "A.1")
  #counter(heading).update(0)
  #include "./appendices/pcformats/pcformats.typ"     //-- A
  #include "./appendices/ahn/ahn.typ"                 //-- B
  #include "./appendices/normalplane/normalplane.typ" //-- C
  #include "./appendices/equations/equations.typ"     //-- D

]


//-- back-matter
// must take page breaks into account, may need to be offset by +1 or -1
// #context counter(page).update(counter(page).at(<front-matter>).first())
// #counter(heading).update(0)
// #let sub-figure-numbering = (super, sub) => numbering("A.1a", counter(heading).get().first(), super, sub)
// #let figure-numbering = super => numbering("A.1", counter(heading).get().first(), super)
// #show figure.where(kind: image): set figure(numbering: figure-numbering)

// #include "appendices/useofai.typ"
// #include "appendices/reproducibility.typ"
// #include "appendices/someumldia.typ"
#pagebreak()


#back-matter[
  //-- references
  #bibliography("./refs/tb.bib", style: "./refs/apa-annotated-bibliography_modified-HL.csl")

  = Index
  #columns(3)[
    #make-index(title: none)
  ]

  #pagebreak()

  #align(bottom)[
    This document was typeset using #link("https://typst.app")[Typst]; its source code is freely available at #link("https://github.com/tudelft3d/terrainbook/").
    // The main font is Palatino.
    // The figures and diagrams were mostly drawn using IPE, PGF/Ti\emph{k}z and Omnigraffle.
  ]
]
