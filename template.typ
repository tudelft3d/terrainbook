
#import "@preview/marginalia:0.3.1" as marginalia: note, notefigure, wideblock
#import "@preview/in-dexter:0.7.2": *
#import "@preview/suboutline:0.3.0": suboutline
#import "@preview/showybox:2.0.4": showybox
//-- headers
#import "@preview/hydra:0.6.2": hydra
//-- subfigure
#import "@preview/subpar:0.2.2"
//-- pseudo-code
#import "@preview/lovelace:0.3.0": *
//-- siunitx
#import "@preview/unify:0.8.1": num, numrange, qty, qtyrange, unit
//-- icons
#import "@preview/heroic:0.1.2": hi

//-- natbib
#let citet = cite.with(form: "prose")
#let citep = cite


//-- for outlines
#let in-outline = state("in-outline", false)
// #set outline.entry(fill: none)
#show outline: it => {
  in-outline.update(true)
  it
  in-outline.update(false)
}
#let flex-caption(long, short) = context {
  if in-outline.at(here()) { long } else { short }
}
#let flex-heading(long, short) = context {
  if in-outline.get() { long } else { short }
}




//-- https://github.com/tingerrr/subpar/issues/16
#let sub-figure-numbering = (super, sub) => numbering("1.1a", counter(heading).get().first(), super, sub)
#let figure-numbering = super => numbering("1.1", counter(heading).get().first(), super)
#let subfigure = subpar.grid.with(
  numbering: figure-numbering,
  numbering-sub-ref: sub-figure-numbering,
  show-sub-caption: (number, caption) => {
    text(size: 8pt, style: "normal", weight: "regular")[#caption]
  },
)

//-- default for pseudo-code/lovelace
#let my-lovelace-defaults = (
  booktabs: true,
  booktabs-stroke: 0.4pt + black,
  hooks: .5em, 
  line-gap: 0.6em,
)
#let pseudocode-list = pseudocode-list.with(..my-lovelace-defaults)

#let note = note.with(counter: none, text-style: (size: 8pt, style: "normal", weight: "regular"))
#let notefigure = notefigure.with(
  // dy: 20pt,
  show-caption: (number, caption) => {
    text(size: 8pt, style: "normal", weight: "regular")[
      #number
      *#caption.supplement #caption.counter.display(caption.numbering)*:
      #caption.body
    ]
  },
)

#let minitoc(toc) = note(dy:17pt)[#showybox(
  frame: (
    body-color: red.lighten(94%),
    inset: 5pt,
    thickness: 0pt,
    // shadow: (
    //   offset: 3pt,
    // ),
  ),
  {
    show outline: it => {
      [#in-outline.update(true)]
      it
      [#in-outline.update(false)]
    }
    toc
  },
)]

#let box-practice(title, body) = figure(placement: auto)[
  #showybox(
    frame: (
      border-color: red.darken(50%),
      title-color: red.lighten(20%),
      body-color: red.lighten(95%),
    ),
    title-style: (
      color: white,
      weight: "bold",
    ),
    shadow: (
      offset: 1pt,
    ),
    title: hi("cog", solid: false) + " " + title,
    body,
  )
]
#let box-toread(title, body) = figure(placement: auto)[
  #showybox(
    frame: (
      border-color: blue.darken(50%),
      title-color: blue.lighten(20%),
      body-color: blue.lighten(95%),
    ),
    title-style: (
      color: white,
      weight: "bold",
    ),
    shadow: (
      offset: 1pt,
    ),
    title:  hi("arrow-top-right-on-square") + " " + title,
    body,
  )
]
#let box-info(title, body) = figure(placement: auto)[
  #showybox(
    frame: (
      border-color: gray.darken(50%),
      title-color: gray.lighten(20%),
      body-color: gray.lighten(95%),
    ),
    title-style: (
      color: white,
      weight: "bold",
    ),
    shadow: (
      offset: 1pt,
    ),
    title: hi("information-circle", solid: false) + " " + title,
    body,
  )
]

#let tbtemplate(
  title: "Computational modelling of terrains",
  authors: (
    "Hugo Ledoux",
    "Ken Arroyo Ohori",
    "Ravi Peters",
    "Maarten Pronk",
  ),
  version: "",
  body,
) = {
  set page(
    // top: 2.5cm,
    // bottom: 2.5cm,
    // margin: auto,
    numbering: "i",
  )

  let serif-fonts = ("TeX Gyre Pagella", "Palatino", "New Computer Modern") //-- https://www.1001fonts.com/tex-gyre-pagella-font.html
  let sans-fonts = ("TeX Gyre Heros", "Source Sans Pro", "Calibri") //-- https://www.1001fonts.com/texgyreheros-font.html + https://github.com/adobe-fonts/source-sans-pro
  let math-font = ("Stix Two Math", "New Computer Modern Math") //-- free: https://github.com/stipub/stixfonts
  let mono-font = ("Consolas", "Monaco") //-- Input Mono Condensed

  set text(
    font: serif-fonts,
    size: 10pt,
  )
  set par(justify: true)
  
  // set heading(numbering: "1.1.1", supplement: none)
  show heading: set text(font: serif-fonts, weight: "bold")

  show heading.where(level: 1): it => counter(figure.where(kind: image)).update(0) + it


  
  show heading.where(level: 1): it => {
    set par(justify: false)
    pagebreak(weak: true, to: "odd")
    // place(top+right)[
    //   #rect(fill: blue, width: 10%, height: 10%)
    // ]
    align(left, text(font: sans-fonts, hyphenate: false, weight: "bold", size: 18pt, it))
    // note(counter(heading).get().first())
    // place(top, note(counter: none, side: "outer")[#text(font: sans-fonts, hyphenate: false, weight: "bold", size: 28pt, "1")])
    v(2em)
  }
  
  // show heading.where(level: 1): it => pagebreak(weak: true, to: "odd") + it.body
  // show heading.where(level: 1): it => align(right, text(font: sans-fonts, hyphenate: false, weight: "bold", size: 18pt, it)) + v(2em)
  show heading.where(level: 2): it => {
    v(3em, weak: true)
    text(font: sans-fonts, size: 14pt, weight: "bold", it)
    v(2em, weak: true)
  }
  show heading.where(level: 3): it => {
    v(3em, weak: true)
    text(font: sans-fonts, size: 11pt, it)
    v(1.5em, weak: true)
  }
  show heading.where(level: 4): it => {
    let title = it.body
    v(1em)
    strong(title + ".") + h(0.8em)
  }
  
  
  show figure.where(kind: image): set figure(numbering: figure-numbering)
  show figure.caption.where(position: bottom): note.with(
     counter: none, shift: "avoid", keep-order: true
  )

  //-- math
  show math.equation: set text(font: math-font)
  set math.equation(numbering: "(1)")
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    it
  }
  
  //-- raw font
  show raw: set text(font: mono-font)

  // Set link style
  show link: it => text(fill: rgb("#3087b3"), font: serif-fonts, it)
  // show link: set text(blue)
  show ref: set text(blue)


  set table.hline(stroke: 0.4pt)
  set table.vline(stroke: 0.4pt)
  
  set list(indent: 1em, tight: true)
  show list: it => v(1.5em, weak: true) + it + v(1.5em, weak: true)
  set enum(indent: 1em, tight: true)
  show enum: it => v(1.5em, weak: true) + it + v(1.5em, weak: true)
  set terms(indent: 1em)
  show terms: it => v(1.5em, weak: true) + it + v(1.5em, weak: true)

  show quote: it => v(1.5em, weak: true) + pad(left: 2em, right: 2em, it) + v(1.5em, weak: true)

  //-- figure caption in the margin + Figure 1.2: in bold
  set figure(gap: 0.55em) // neccessary in both cases
  set figure.caption(position: bottom)
  //--
  // show figure.caption.where(position: bottom): note.with(
  //   alignment: "bottom", 
  //   counter: none, 
  //   shift: "avoid", 
  //   keep-order: true,
  //   // text-style: (size: 10pt, weight: "bold"),
  // )
  //-- OR
  set figure.caption(position: bottom)
  show figure.caption: it => note(
    // dy: 45pt,
    alignment: "bottom",
    counter: none,
    shift: "avoid",
    keep-order: true,
  )[*#it.supplement #it.counter.display(it.numbering)*: #it.body]
  //-- 

  // Title page: unnumbered, and reset counter so next page is I
  if title != none {
    [
      #set page(numbering: none)
      #counter(page).update(0)
      #align(center)[
        #v(5cm)
        #text(font: sans-fonts, size: 20pt, weight: "bold", title)
        // #title \
        #grid(
          columns: (5cm, 5cm),
          inset: 5pt,
          text(1.2em, "Hugo Ledoux"),
          text(1.2em, "Ken Arroyo Ohori"),
          text(1.2em, "Ravi Peters"),
          text(1.2em, "Maarten Pronk"),
        )
        #v(5mm)
        #text(font: mono-font, size: 10pt, version)
      ]
      // #pagebreak()
    ]
  }
  body
}

// Front matter: Roman numerals, remember last page via metadata
#let front-matter(body) = {
  set page(numbering: "i")
  counter(page).update(1)
  body
  // // store the last front-matter page number
  // context [#metadata(counter(page).get()) <front-matter>]
}

// Main matter: Arabic numerals from 1
#let main-matter(body) = {
  set page(header: context {
    if calc.odd(here().page()) {
      if hydra(1) != none {
        // place(
          // dx: 100mm, // negative = move left, toward the outside edge
          // dy: 1cm,
          // align(left, emph(hydra(1)))
        // )
        // move(dy: 3mm, line(stroke: 0.6pt, start: (173mm, 20mm), end: (173mm, -50mm)))
        // place(right, emph(hydra(1) + " • " + counter(page).display() + [🚀]))
        // marginalia.header(text-style: (size: 10pt), align(right, emph(hydra(2))), [hugo],  counter(page).display())
        marginalia.header(text-style: (size: 10pt, style: "italic"), [], align(right, hydra(1)), align(right, counter(page).display()))
        // marginalia.header(text-style: (size: 10pt), [a], [b], align(right, emph(hydra(2) + h(1cm) + counter(page).display())))
      }
      // align(right, emph(hydra(1) + " | " + counter(page).display()))
    } else {
      marginalia.header(text-style: (size: 10pt, style: "italic"), [], align(left, hydra(2)), align(left, counter(page).display()))
      // move(dy: 3mm, line(stroke: 0.6pt, start: (-53mm, 20mm), end: (-53mm, -50mm)))
      // marginalia.header(text-style: (size: 10pt), [], [], align(left, counter(page).display() + h(1cm) + emph(hydra(1))))
    }
    // line(length: 100%)
  })
  // set page(numbering: "1")
  set page(numbering: "1", number-align: top+right)
  counter(page).update(1)
  set heading(numbering: "1.1.1")
  show heading.where(level: 1): set heading(supplement: [Chapter])
  show: marginalia.setup.with(
    // A4: 210mm x 297mm
    inner: (far: 10mm, width: 5mm, sep: 5mm),
    outer: (far: 10mm, width: 55mm, sep: 5mm),
    // main text is 120mm
    // inner: (far: 15mm, width: 0mm, sep: 5mm),
    // outer: (far: 15mm, width: 50mm, sep: 5mm),
    top: 2.5cm,
    bottom: 2.5cm,
    book: true,
    clearance: 12pt,
  )
  show heading.where(level: 1): it => {
    set par(justify: false)
    counter(figure.where(kind: image)).update(0)
    pagebreak(weak: true, to: "odd")
    block(
      width: 100%,
      // height: 4em,
      // above: 2em,
      below: 2em,
      // inset: 1em,
      // fill: luma(97%),
      grid(
        columns: (120mm, 5mm, 1fr),
        align: (right, center, left),
        place(
          bottom+right,
  			  text(
            size: 1.8em,
  					it.body,
  			  )
        ),
        // place(bottom+center, 
        //   line(stroke: 0.6pt, start: (0mm, 0mm), end: none, angle: 90deg, length: 100%), 
        // ),
        move(dy:3mm, line(stroke: 0.6pt, start: (0mm, 20mm), end: (0mm, -50mm))), 
        place(
          bottom+left,
          text(
    				size: 6em,
    				weight: "semibold",
    				style: "italic",
    				fill: luma(25%),
    				counter(heading).display(),
    			)
        )
      )
    )
  }  
  // --
  // show: marginalia.show-frame
  //--
  // set page(
  //   header: context if here().page() > 1 {
  //     marginalia.header(
  //       text-style: (size: 8pt),
  //       // [Page #counter(page).display("1 of 1", both: true)],
  //       // [#smallcaps[Marginalia] #text(fill: luma(60%))[ledoux]],
  //       [#counter(page).display() --- ],
  //     )
  //   },
  // )
  body
}

// Back matter: Roman numerals continuing from front matter
#let back-matter(body) = {
  set page(numbering: none)
  set heading(numbering: none)
  counter(heading).update(0)
  set page(
    header: none
  )

  body
}
  //
