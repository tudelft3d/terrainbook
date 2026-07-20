#import "template.typ": *

#show: doc => tbtemplate(
  title: "Computational modelling of terrains",
  author: "Hugo Ledoux et al.",
  version: "v2026.0beta1",
  doc,
)


#front-matter[
  #include "front-back/pre.typ"
  #include "front-back/preface.typ"
  
  #[
    #show outline.entry.where(
      level: 1,
    ): it => {
      v(12pt, weak: true)
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
#main-matter[

  //-- main chapters

  #include "whatisterrain/whatisterrain.typ"
  #include "acquisition/acquisition.typ"
  #include "interpol/interpol.typ"
  // #include "dtvd/dtvd.typ"
  // #include "runoff/runoff.typ"
  // #include "whatisterrain/whatisterrain_fixed.typ"
  // #include "visibility/visibility.typ"
  // #include "conversion/conversion.typ"
  // #include "spatialextent/spatialextent.typ"
  // #include "dtvd/dtvd_fixed.typ"
  // #include "runoff/runoff_fixed.typ"

  //-- Appendices
  #set heading(numbering: "A.1")
  #counter(heading).update(0)
  #include "./appendices/pcformats/pcformats.typ"     //-- A
  #include "./appendices/ahn/ahn.typ"                 //-- B
  // #include "./appendices/normalplane/normalplane.typ" //-- C
  // #include "./appendices/equations/equations.typ"     //-- D

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
]
