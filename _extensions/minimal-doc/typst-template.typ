#let minimal(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  version: none,
  header: none,
  title-only: false,
  titleinheader: true,
  authorsinheader: false,
  cols: 1,
  margin: (x: 20mm, top: 20mm, bottom: 30mm),
  paper: "a4",
  lang: "en",
  region: "UK",
  font: "libertinus serif",
  fontsize: 10pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: "libertinus serif",
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  sectionnumbering: none,
  pagenumbering: "1",
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  // parse arguments
  if not titleinheader {
    titleinheader = false
  }

  // if header is unset so far, start assembling it
  if header == none {
    // if title is specified, add it to the header
    if title != none and titleinheader {
      header = title
    }

    // if a version unmber is specified, add it to the header
    if version != none {
      if header != none {
        header = header + " v" + version
      } else {
        header = "v" + version
      }
    }

    // if authors are specified, add them to the header
    if authors != none and authorsinheader {
      let by_author = authors.first().name
      if authors.len() > 1 {
        by_author = by_author + " et al."
      }
      if header != none {
        header = header + " by " + by_author
      } else {
        header = by_author
      }
    }

    // if date is specified, add it to the header
    if date != none {
      if header != none {
        header = header + " – " + date
      } else {
        header = date
      }
    } else {
      if header != none {
        header = header + " – " + datetime.today().display()
      } else {
        header = datetime.today().display()
      }
    }
  }

  set page(
    paper: paper,
    margin: margin,
    numbering: pagenumbering,
    header: align(right)[
      #set text(9pt)
      #header
      // #line(length: 100%)
    ]
  )
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)
  set table(
    inset: 6pt,
    stroke: none
  )
  show figure: set block(breakable: true)

  if title != none {
    align(center)[
      #block(inset: 1em)[
        #set par(leading: heading-line-height)
        #if (heading-family != none
            or heading-weight != "bold"
            or heading-style != "normal"
            or heading-color != black) {
          set text(font: heading-family, weight: heading-weight, style: heading-style, fill: heading-color)
          text(size: title-size)[#title]
          if not title-only and subtitle != none {
            parbreak()
            text(size: subtitle-size)[#subtitle]
          }
        } else {
          text(weight: "bold", size: title-size)[#title]
          if not title-only and subtitle != none {
            parbreak()
            text(weight: "semibold", size: subtitle-size)[#subtitle]
          }
        }

        #if not title-only {
          if authors != none {
            let list_authors = ()
            for author in authors {
              list_authors.push(author.name)
            }
            parbreak()
            list_authors.join(", ", last: " and ")
          }
          if date != none {
            parbreak()
            date
          }
        }
      ]
    ]


    if abstract != none {
      block(inset: 2em)[
      #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
      ]
    }

    if toc {
      let title = if toc_title == none {
        auto
      } else {
        toc_title
      }
      block(above: 0em, below: 2em)[
      #outline(
        title: toc_title,
        depth: toc_depth,
        indent: toc_indent
      );
      ]
    }

    v(0.25em)
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}
