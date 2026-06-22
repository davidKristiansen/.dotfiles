// cv.typ — Reusable CV template with sidebar, header, and color-cycling sections
// Usage:
//   #import "@local/cv:0.1.0": cv, heading, entry, sidebar-entry
//   #show: cv.with(
//     first-name: "emma",
//     last-name: "nekstad",
//     subtitle: "student på kirkeparken vgs",
//     street: "Binneveien 48",
//     zip: "1596",
//     city: "Moss",
//     email: "emmatherese08@icloud.com",
//     phone: "+47 977 67 046",
//     photo: image("face.jpeg"),
//   )
//   #sidebar-entry[språk][norsk morsmål \ english flytende]
//   #sidebar-entry[interesser][dyr, snowboard, trening]
//
//   #heading("utdannelse")
//   #entry(start: 2024, title: "Studiespesialiserende", location: "Kirkeparken vgs")
//   ...

// ── Color palette ──────────────────────────────────────
#let default-accent-colors = (
  rgb("#66D9EE"), // blue
  rgb("#FFC0CB"), // pink
  rgb("#FE9720"), // orange
  rgb("#A7E22E"), // green
  rgb("#9358FE"), // purple
  rgb("#36AF90"), // aquamarine
)

#let default-gray-dark  = rgb("#333333")
#let default-gray-mid   = rgb("#4D4D4D")
#let default-gray-light = rgb("#999999")
#let default-date-color = rgb("#A4A4A4")
#let default-header-bg  = rgb("#4D4D4D")

// ── State ──────────────────────────────────────────────
#let color-counter = counter("section-color")
#let accent-state = state("cv-accent-colors", default-accent-colors)
#let gray-dark-state = state("cv-gray-dark", default-gray-dark)

// State to collect sidebar entries from the body
#let sidebar-state = state("cv-sidebar-sections", ())

// ── Sidebar entry (exported) ───────────────────────────
// Call in body to add a section to the sidebar.
// Renders nothing in the main flow; content appears in the sidebar.
#let sidebar-entry(title, body) = {
  sidebar-state.update(old => old + ((title: title, body: body),))
}

// ── Section heading (exported) ─────────────────────────
#let heading(title) = {
  color-counter.step()
  v(1em)
  context {
    let colors = accent-state.get()
    let gd = gray-dark-state.get()
    let idx = calc.rem(color-counter.get().first() - 1, colors.len())
    let col = colors.at(idx)
    text(
      size: 16pt,
      weight: "bold",
      fill: gd,
    )[#text(fill: col, title.first())#title.slice(1)]
  }
  v(0.5em)
}

// ── Entry helper (exported) ────────────────────────────
#let entry(
  start: none,
  end: none,
  title: "",
  location: "",
  description: "",
  gray-light: default-gray-light,
) = {
  let date-display = if start == none { [] } else {
    let s = if type(start) == int { str(start) } else { start }
    if end != none {
      let e = if type(end) == int { str(end) } else { end }
      [#s\u{2013}#e]
    } else {
      [#s\u{2013}#hide[0000]]
    }
  }
  grid(
    columns: (auto, 1fr),
    column-gutter: 1.2em,
    text(size: 10pt, fill: gray-light, font: "IBM Plex Mono", date-display),
    {
      if title != "" or location != "" {
        [*#title* #h(1fr) #text(size: 9pt, fill: gray-light, location)]
      }
      if description != "" {
        if title != "" or location != "" { linebreak() }
        description
      }
      v(6pt)
    },
  )
}

// ── Localized labels ───────────────────────────────────
#let locale-labels(lang) = {
  if lang == "nb" or lang == "nn" or lang == "no" {
    (contact: "kontaktinfo", updated: "Sist oppdatert")
  } else if lang == "sv" {
    (contact: "kontaktinfo", updated: "Senast uppdaterad")
  } else if lang == "da" {
    (contact: "kontaktinfo", updated: "Sidst opdateret")
  } else if lang == "de" {
    (contact: "Kontaktinfo", updated: "Zuletzt aktualisiert")
  } else if lang == "fr" {
    (contact: "contact", updated: "Dernière mise à jour")
  } else {
    (contact: "contact info", updated: "Last updated")
  }
}

// ── Localized month names ──────────────────────────────
#let locale-months(lang) = {
  if lang == "nb" or lang == "nn" or lang == "no" {
    ("januar", "februar", "mars", "april", "mai", "juni",
     "juli", "august", "september", "oktober", "november", "desember")
  } else if lang == "sv" {
    ("januari", "februari", "mars", "april", "maj", "juni",
     "juli", "augusti", "september", "oktober", "november", "december")
  } else if lang == "da" {
    ("januar", "februar", "marts", "april", "maj", "juni",
     "juli", "august", "september", "oktober", "november", "december")
  } else if lang == "de" {
    ("Januar", "Februar", "März", "April", "Mai", "Juni",
     "Juli", "August", "September", "Oktober", "November", "Dezember")
  } else if lang == "fr" {
    ("janvier", "février", "mars", "avril", "mai", "juin",
     "juillet", "août", "septembre", "octobre", "novembre", "décembre")
  } else {
    ("January", "February", "March", "April", "May", "June",
     "July", "August", "September", "October", "November", "December")
  }
}

// ── Main show rule ─────────────────────────────────────
#let cv(
  // Identity
  first-name: none,
  last-name: none,
  subtitle: none,
  // Contact
  street: none,
  zip: none,
  city: none,
  email: none,
  phone: none,
  // Sidebar
  photo: none,                       // pass image(...) content
  // Style
  font: "IBM Plex Sans",
  heading-font: "IBM Plex Sans",
  accent-colors: default-accent-colors,
  gray-dark: default-gray-dark,
  gray-mid: default-gray-mid,
  gray-light: default-gray-light,
  date-color: default-date-color,
  header-bg: default-header-bg,
  last-updated: datetime.today(),    // datetime, string, or none to hide
  lang: "nb",
  // Sidebar layout
  sidebar-width: 3.6cm,
  sidebar-padding: 1.5cm,
  // Content
  body,
) = {
  accent-state.update(accent-colors)
  gray-dark-state.update(gray-dark)

  let labels = locale-labels(lang)

  // ── Page setup ───────────────────────────────────────
  let total-sidebar = sidebar-padding + sidebar-width + sidebar-padding
  set page(
    paper: "a4",
    margin: (left: total-sidebar, top: 5cm, right: 1.5cm, bottom: 1.5cm),
    background: {
      // ── Header (full width dark bar) ───────────────────
      let full-name-first = if first-name != none { first-name } else { "" }
      let full-name-last = if last-name != none { last-name } else { "" }

      place(
        top + left,
        block(
          width: 21cm,
          height: 4cm,
          fill: header-bg,
          align(center + horizon, {
            text(
              size: 40pt,
              fill: white,
              font: font,
              weight: "thin",
            )[#full-name-first]
            text(
              size: 40pt,
              fill: white,
              font: font,
              weight: "regular",
            )[ #full-name-last]
            if subtitle != none {
              linebreak()
              text(
                size: 14pt,
                fill: white,
                font: font,
                weight: "thin",
              )[#subtitle]
            }
          }),
        ),
      )

      // ── Last Updated ─────────────────────────────────────
      if last-updated != none {
        let date-str = if type(last-updated) == datetime {
          let months = locale-months(lang)
          let d = str(last-updated.day())
          let m = months.at(last-updated.month() - 1)
          let y = str(last-updated.year())
          d + ". " + m + " " + y
        } else {
          last-updated
        }
        place(
          top + right,
          dx: -1cm,
          dy: 0.2cm,
          text(
            size: 8pt,
            fill: date-color,
            font: font,
            weight: "thin",
          )[#labels.updated #date-str],
        )
      }
    },
    foreground: {
      // ── Sidebar (in foreground so state is available) ─────
      context {
        let sections = sidebar-state.get()
        place(
          top + left,
          dx: sidebar-padding,
          dy: 4cm,
          block(width: sidebar-width, {
            set align(right)
            set text(size: 9pt, font: font, fill: gray-mid)

            v(1cm)

            // Photo
            if photo != none {
              block(
                clip: true,
                width: 100%,
                stroke: 0.5pt + gray-light,
                photo,
              )
            }

            // Contact info
            if street != none or email != none or phone != none {
              v(0.8cm)
              text(
                size: 12pt,
                fill: gray-dark,
                font: heading-font,
                weight: "bold",
              )[#labels.contact]
              linebreak()
              v(0.3cm)
              if street != none {
                text(size: 9pt)[#street]
                linebreak()
              }
              if zip != none and city != none {
                [#zip #city]
              }
              v(0.5cm)
              if phone != none {
                link("tel:" + phone.replace(" ", ""))[#phone]
                linebreak()
              }
              if email != none {
                link("mailto:" + email)[#text(size: 8pt)[#email]]
              }
            }

            // Extra sections from sidebar-entry() calls
            for section in sections {
              v(0.8cm)
              text(
                size: 12pt,
                fill: gray-dark,
                font: heading-font,
                weight: "bold",
              )[#section.title]
              linebreak()
              v(0.3cm)
              section.body
            }
          }),
        )
      }
    },
  )

  set text(
    font: font,
    weight: "light",
    size: 10pt,
    fill: gray-mid,
    lang: lang,
  )

  set par(leading: 0.9em)

  show raw: set text(font: "IBM Plex Mono")

  // ── Body ─────────────────────────────────────────────
  body
}
