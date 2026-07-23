
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
#import "@preview/unify:0.8.1": num, numrange, qty, qtyrange
//-- icons
#import "@preview/heroic:0.1.2": hi

//-- natbib
#let citet = cite.with(form: "prose")
#let citep = cite


//-- for outlines
#let in-outline = state("in-outline", false)
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

#let box-practice(title, body) = showybox(
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
#let box-toread(title, body) = showybox(
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
#let box-info(title, body) = showybox(
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
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    it
  }
  //-- raw font
  show raw: set text(font: mono-font)

  // Set link style
  show link: it => text(fill: rgb("#3087b3"), font: mono-font, it)
  show ref: set text(blue)
  
  // show link: set text(blue)

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
  // set figure.caption(position: bottom)
  show figure.caption: it => note(
    // dy: 45pt,
    alignment: "bottom",
    counter: none,
    shift: "avoid",
    keep-order: true,
  )[*#it.supplement #it.counter.display(it.numbering)*: #it.body]

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
  set page(numbering: "1")
  counter(page).update(1)
  set heading(numbering: "1.1.1", supplement: none)
  show: marginalia.setup.with(
    inner: (far: 10mm, width: 5mm, sep: 5mm),
    outer: (far: 10mm, width: 55mm, sep: 5mm),
    // inner: (far: 15mm, width: 0mm, sep: 5mm),
    // outer: (far: 15mm, width: 50mm, sep: 5mm),
    top: 2.5cm,
    bottom: 2.5cm,
    book: true,
    clearance: 12pt,
  )
  show: marginalia.show-frame
  set page(
    header: [
      #h(1fr) TODO: make a good header!
    ],
  )
  // set page(
  //   header: context if here().page() > 1 {
  //     marginalia.header(
  //       text-style: (size: 8pt),
  //       // [Page #counter(page).display("1 of 1", both: true)],
  //       [#smallcaps[Marginalia] #text(fill: luma(60%))[ledoux]],
  //       [#counter(page).display()],
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
  // set page(
    // top: 2.5cm,
    // bottom: 2.5cm,
    // margins: 10mm,
    // numbering: "I",
  // )

  body
}
  //
