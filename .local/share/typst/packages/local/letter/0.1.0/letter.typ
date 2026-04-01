// letter.typ — Reusable cover-letter template (scrlttr2 / DIN 5008 style)
// Usage:
//   #import "@local/letter:0.1.0": letter
//   #show: letter.with(
//     name: "Emma Nekstad",
//     street: "Binneveien 48",
//     zip: "1596",
//     city: "Moss",
//     email: "emmatherese08@icloud.com",
//     phone: "+47 977 67 046",
//     recipient: [Sunkost Rygge \ att. Kari Larsen],
//     subject: "Søknadsbrev",
//     closing: "Med vennlig hilsen,",
//   )
//   Body text goes here as normal content...

#let letter(
  // Sender
  name: none,
  street: none,
  zip: none,
  city: none,
  email: none,
  phone: none,
  // Recipient
  recipient: none,
  // Letter
  subject: none,
  date: datetime.today(),           // datetime or string to override
  opening: none,                    // e.g. "Hei Kari Larsen,"
  closing: "Med vennlig hilsen,",
  // Style
  font: "IBM Plex Serif",          // Serif font for body text (brødtekst)
  sans-font: "IBM Plex Sans",      // Sans-serif for sender, recipient, subject, closing
  font-size: 11pt,
  lang: "nb",
  icon-indent: 1.5em,
  icon-size: 10pt,
  // Fold marks (DIN 5008)
  fold-marks: true,
  // Content
  body,
) = {
  // ── scrlttr2 DIN layout constants ──────────────────
  // typearea DIV=12 for A4 (210×297mm):
  //   hblk = 17.5mm, vblk = 24.75mm
  //   left margin  = 1.5 × hblk = 26.25mm
  //   right margin = 1.5 × hblk = 26.25mm
  //   top margin   = 1   × vblk = 24.75mm
  //   bottom margin= 2   × vblk = 49.50mm
  //   text width   = 157.5mm, text height = 222.75mm
  //
  // DIN.lco positions (from page edge):
  //   sender:    8mm top,  20mm left,  170mm wide
  //   recipient: 45mm top, 20mm left,  85mm wide, 45mm tall
  //   ref line:  98.5mm top
  //   fold marks: 3.5mm from left, at 105mm and 210mm

  let margin-left = 26.25mm
  let margin-right = 26.25mm
  let margin-top = 24.75mm
  let margin-bottom = 49.5mm

  let sender-hpos = 20mm
  let sender-vpos = 8mm
  let sender-width = 170mm

  let recip-hpos = 20mm
  let recip-vpos = 62mm
  let recip-width = 85mm
  let recip-height = 45mm

  let ref-vpos = 98.5mm

  // ── Page setup ─────────────────────────────────────
  set page(
    paper: "a4",
    margin: (
      top: ref-vpos,
      bottom: margin-bottom,
      left: margin-left,
      right: margin-right,
    ),
    background: {
      // ── Fold marks ─────────────────────────────────
      if fold-marks {
        let mark-len = 3mm
        let mark-x = 3.5mm
        let s = 0.5pt + black
        // Upper fold mark (105mm)
        place(top + left, dx: mark-x, dy: 105mm)[#line(length: mark-len, stroke: s)]
        // Lower fold mark (210mm)
        place(top + left, dx: mark-x, dy: 210mm)[#line(length: mark-len, stroke: s)]
      }

      // ── Sender block (absolute position, sans-serif) ──
      place(top + left, dx: sender-hpos, dy: sender-vpos)[
        #block(width: sender-width)[
          #set text(font: sans-font, size: font-size, fill: black, lang: lang)
          #set par(leading: 0.65em, spacing: 0.65em * 2)
          #let fa-icon(code) = text(font: "FontAwesome", size: icon-size)[#code]
          #let ie = fa-icon[\u{f0e0}]
          #let ip = fa-icon[\u{f095}]
          #pad(left: icon-indent)[
            #align(left)[
              #name \
              #street \
              // Format date: use localized month name if datetime, or pass through string
              #let date-str = if type(date) == datetime {
                let months = if lang == "nb" or lang == "nn" or lang == "no" {
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
                let d = str(date.day())
                let m = months.at(date.month() - 1)
                let y = str(date.year())
                d + ". " + m + " " + y
              } else {
                date
              }
              #zip #smallcaps[#city] #h(1fr) #city, #date-str \
              #h(-icon-indent)#ie #h(0.3em) #link("mailto:" + email)[#text(size: icon-size)[#email]] \
              #h(-icon-indent)#ip #h(0.3em) #link("tel:" + phone.replace(" ", ""))[#text(size: icon-size)[#phone]]
            ]
          ]
        ]
      ]

      // ── Recipient block (absolute position, sans-serif) ──
      if recipient != none {
        place(top + left, dx: recip-hpos, dy: recip-vpos)[
          #block(width: recip-width, height: recip-height)[
            #set text(font: sans-font, size: font-size, fill: black, lang: lang)
            #set par(leading: 0.65em)
            #recipient
          ]
        ]
      }
    },
  )

  // ── Body text style (serif) ────────────────────────
  set text(
    font: font,
    size: font-size,
    fill: black,
    lang: lang,
  )

  // ── Monospace font for raw/code elements ───────────
  show raw: set text(font: "IBM Plex Mono")

  set par(
    justify: true,
    leading: 0.65em,
    first-line-indent: 0em,
    spacing: 0.65em * 2,
  )

  // ── Subject (sans-serif, bold) ─────────────────────
  if subject != none {
    text(font: sans-font)[#strong(subject + ".")]
  }

  // 2 baselines after subject before opening (scrlttr2 default)
  v(0.65em * 2)

  // ── Opening ────────────────────────────────────────
  if opening != none {
    opening
    v(0.65em)
  }

  // ── Body (serif) ───────────────────────────────────
  body

  // ── Closing (sans-serif) ───────────────────────────
  v(1fr)

  text(font: sans-font)[#closing]

  v(0.8cm)

  text(font: sans-font)[#name]
}
