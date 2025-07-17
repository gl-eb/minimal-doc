# Changelog

## 0.6.1

- Fix subtitle logic if `title-only: yes`

## 0.6.0

- Add option to only show title in title block (i.e. no subtitle, authors, or date)
- Introduce changes made to template files in `quarto-cli` (up to v1.8.17)
  - Allow styling headings
  - Allow styling table of contents
  - Allow setting abstract title
  - Allow changing page numbering

## 0.5.0

- Slightly restyle title block to make it more compact

## 0.4.0

- Tables follow default Pandoc behaviour

## 0.3.0

- Allow removing document title from header

## 0.2.1

- Do not start the header with "by author" but with "author" instead
- Use long date format for example document

## 0.2.0

- Omit the whole title block if the user does not supply a document title
- Also add a "v" in front of the version number in the header if no title is supplied by the user

## 0.1.1

- Respect user-speficied dates

## 0.1.0

Initial release
