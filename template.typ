// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): block.with(
    fill: luma(230), 
    width: 100%, 
    inset: 8pt, 
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.amount
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == "string" {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == "content" {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

#show figure: it => {
  if type(it.kind) != "string" {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    new_title_block +
    old_callout.body.children.at(1))
}

#show ref: it => locate(loc => {
  let suppl = it.at("supplement", default: none)
  if suppl == none or suppl == auto {
    it
    return
  }

  let sup = it.supplement.text.matches(regex("^45127368-afa1-446a-820f-fc64c546b2c5%(.*)")).at(0, default: none)
  if sup != none {
    let target = query(it.target, loc).first()
    let parent_id = sup.captures.first()
    let parent_figure = query(label(parent_id), loc).first()
    let parent_location = parent_figure.location()

    let counters = numbering(
      parent_figure.at("numbering"), 
      ..parent_figure.at("counter").at(parent_location))
      
    let subcounter = numbering(
      target.at("numbering"),
      ..target.at("counter").at(target.location()))
    
    // NOTE there's a nonbreaking space in the block below
    link(target.location(), [#parent_figure.at("supplement") #counters#subcounter])
  } else {
    it
  }
})

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      block(
        inset: 1pt, 
        width: 100%, 
        block(fill: white, width: 100%, inset: 8pt, body)))
}

#let minimal(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  version: none,
  header: none,
  titleinheader: true,
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
    numbering: "1",
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

  if title != none {
    align(center)[#block(inset: 1em)[
      #text(weight: "bold", size: 1.5em)[#title]
    ]]

    if subtitle != none {
      align(center)[
        #text(weight: "bold", size: 1.25em)[#subtitle]
      ]
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
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}
// Typst custom formats typically consist of a 'typst-template.typ' (which is
// the source code for a typst template) and a 'typst-show.typ' which calls the
// template's function (forwarding Pandoc metadata values as required)

#show: doc => minimal(
  title: [A Minimal Document Template],
  subtitle: [v0.2.1],
  authors: (
    ( name: [Gleb Ebert],
      affiliation: [],
      email: [] ),
    ),
  date: [April 15, 2024],
  lang: "en",
  version: "0.2.1",
  authorsinheader: true,
  margin: (bottom: 30mm,top: 20mm,x: 20mm,),
  cols: 1,
  doc,
)


= Introduction
<introduction>
This template gets rid of much of the white space that you find in most title blocks, reduces page margins and uses a smaller default font size of 10pt. Thus more text fits on one page. It also features a header that includes identifying information of the document.

= Installation
<installation>
== Creating a New Project
<creating-a-new-project>
You can use this Minimal Document template to start a new project by running the following command in the terminal:

```bash
quarto use template gl-eb/minimal-doc
```

== Using the Template in an Existing Project
<using-the-template-in-an-existing-project>
You can install this Minimal Document template into an existing project by running the following command in the terminal:

```bash
quarto add gl-eb/minimal-doc
```
