#let minimal(
  title: none,
  authors: none,
  date: none,
  abstract: none,
  version: none,
  header: none,
  authorsinheader: false,
  cols: 1,
  margin: (x: 20mm, top: 20mm, bottom: 30mm),
  paper: "a4",
  lang: "en",
  region: "UK",
  font: (),
  fontsize: 10pt,
  sectionnumbering: none,
  toc: false,
  doc,
) = {
  // if header is unset so far, start assembling it
  if header == none {
    // if title is specified, add it to the header
    if title != none {
      header = title
    }

    // if a version unmber is specified, add it to the header
    if version != none {
      if header != none {
        header = header + " v" + version
      } else {
        header = version
      }
    }

    // if authors are specified, add them to the header
    if authors != none and authorsinheader == true {
      let by_author = authors.first().name
      if authors.len() > 1 {
        by_author = by_author + " et al."
      }
      if header != none {
        header = header + " by " + by_author
      } else {
        header = " by " + by_author
      }
    }

    // if date is specified, add it to the header
    if date != none {
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
    numbering: "1",
    header: align(right)[
      #set text(9pt)
      #header
    ]
  )
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)

  if title != none {
    align(center)[#block(inset: 1em)[
      #text(weight: "bold", size: 1.5em)[#title]
    ]]
  }

  if authors != none {
    let list_authors = ()
    for author in authors {
      list_authors.push(author.name)
    }
    list_authors = list_authors.join(", ", last: " and ")
    align(center)[#list_authors]
  }

  if date != none {
    align(center)[#date]
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[Abstract] #h(1em) #abstract
    ]
  }

  if toc {
    block(above: 0em, below: 2em)[
    #outline(
      title: auto,
      depth: none
    );
    ]
  }

  v(0.25em)

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}
