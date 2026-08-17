// ─────────────────────────────────────────────────────────────
//  invitation — a reusable kids' party invitation template
//
//  The template holds no wording of its own: every string is
//  supplied by the caller, so the same layout works for any
//  language, age or occasion. The body of the card is a generic
//  list of detail entries (label + lines), coloured by cycling
//  through the palette.
//
//  Usage:
//    #import "@local/invitation:0.1.0": invitation
//    #invitation(
//      name: "Robin",
//      age: "7",
//      kicker: "You are invited",
//      tagline: [is turning seven!],
//      details: (
//        (label: "When", lines: ("Saturday 3 May", "14:00 - 17:00")),
//        (label: "Where", lines: "The community hall"),
//        (label: "Bring", lines: "nothing but yourself"),
//      ),
//      rsvp: "Reply by 26 April",
//      rsvp-note: "to a-parent@example.com",
//    )
//
//  Detail entries are a plain list, so callers decide how many rows
//  there are and what they say. Each entry is a dictionary with
//  `label`, `lines` (a string or an array of strings) and an optional
//  `color` that overrides the cycled palette colour.
// ─────────────────────────────────────────────────────────────

// ══ Palette ══════════════════════════════════════════════════
#let coral = rgb("#ff6b6b")
#let teal = rgb("#2ec4b6")
#let sunny = rgb("#ffc93c")
#let violet = rgb("#9d6bd4")
#let ocean = rgb("#4d96ff")
#let cream = rgb("#fffaf2")
#let ink = rgb("#3d3546")

#let default-palette = (coral, teal, sunny, violet, ocean)

// A5 portrait — the size of a single invitation.
#let card-width = 148mm
#let card-height = 210mm

// ══ Helpers ══════════════════════════════════════════════════

// Accept either a single value or an array of them.
#let as-array(value) = if type(value) == array { value } else { (value,) }

// Deterministic pseudo-random numbers in [0, 1). A fixed seed keeps the
// confetti identical on every compile, so reprints match earlier ones.
#let random-units(seed, count) = {
  let out = ()
  let s = seed
  for _ in range(count) {
    s = calc.rem(s * 1103515245 + 12345, 2147483648)
    out.push(s / 2147483648.0)
  }
  out
}

// Scatter confetti inside a band of the card. Must be called from a
// context whose container is the card itself.
#let confetti(
  seed: 1,
  count: 20,
  y: (0mm, 40mm),
  x: (6mm, 142mm),
  palette: default-palette,
) = {
  let r = random-units(seed, count * 5)
  for i in range(count) {
    let px = x.at(0) + r.at(i * 5) * (x.at(1) - x.at(0))
    let py = y.at(0) + r.at(i * 5 + 1) * (y.at(1) - y.at(0))
    let paint = palette.at(calc.rem(int(r.at(i * 5 + 2) * 1000), palette.len()))
    let turn = r.at(i * 5 + 3) * 360deg
    let shape = int(r.at(i * 5 + 4) * 3)
    place(top + left, dx: px, dy: py, rotate(turn, {
      if shape == 0 {
        rect(width: 1.6mm, height: 3.2mm, fill: paint, radius: 0.4mm, stroke: none)
      } else if shape == 1 {
        circle(radius: 1.1mm, fill: paint, stroke: none)
      } else {
        polygon(fill: paint, (0mm, 0mm), (2.6mm, 0mm), (1.3mm, 2.4mm))
      }
    }))
  }
}

// A balloon with a curling string, optionally carrying a label.
#let balloon(width, height, paint, label: none, string: 20mm, mirror: false) = box(
  width: width,
  height: height + 3mm + string,
  {
    place(top + center, ellipse(
      width: width,
      height: height,
      fill: paint,
      stroke: none,
      align(center + horizon, label),
    ))
    // Knot below the balloon
    place(top + center, dy: height - 1mm, polygon(
      fill: paint,
      (0mm, 0mm),
      (1.8mm, -1.4mm),
      (3.6mm, 0mm),
      (1.8mm, 2.6mm),
    ))
    place(top + center, dy: height + 1.6mm, curve(
      stroke: 0.7pt + paint.darken(12%),
      curve.move((0mm, 0mm)),
      curve.cubic(
        (if mirror { -6mm } else { 6mm }, string * 0.35),
        (if mirror { 6mm } else { -6mm }, string * 0.72),
        (0mm, string),
      ),
    ))
  },
)

// A carnival / masquerade mask. `eye` should match the card background
// so the eye holes read as cut-outs rather than as painted dots.
#let carnival-mask(width: 26mm, paint: violet, eye: cream) = {
  let h = width * 0.42
  let w = width
  box(width: w, height: h * 1.1, {
    // Ribbons trailing off to either side
    for side in (-1, 1) {
      place(top + left, dx: w * 0.5, dy: h * 0.4, curve(
        stroke: 0.7pt + paint,
        curve.move((0mm, 0mm)),
        curve.cubic(
          (side * w * 0.35, -h * 0.22),
          (side * w * 0.55, h * 0.18),
          (side * w * 0.68, -h * 0.05),
        ),
      ))
    }
    // Mask body: dips in the middle at the top, notched for the nose below
    place(top + left, curve(
      fill: paint,
      stroke: none,
      curve.move((0mm, h * 0.34)),
      curve.cubic((w * 0.06, -h * 0.06), (w * 0.34, -h * 0.04), (w * 0.5, h * 0.13)),
      curve.cubic((w * 0.66, -h * 0.04), (w * 0.94, -h * 0.06), (w, h * 0.34)),
      curve.cubic((w, h * 0.88), (w * 0.72, h * 1.06), (w * 0.5, h * 0.6)),
      curve.cubic((w * 0.28, h * 1.06), (0mm, h * 0.88), (0mm, h * 0.34)),
      curve.close(),
    ))
    for dx in (w * 0.16, w * 0.6) {
      place(top + left, dx: dx, dy: h * 0.3, ellipse(
        width: w * 0.24,
        height: h * 0.4,
        fill: eye,
        stroke: none,
      ))
    }
  })
}

// One entry in the detail list: a coloured bullet, a small caps label,
// and one or more lines of text.
#let detail-row(label, lines, paint) = grid(
  columns: (5mm, 1fr),
  column-gutter: 3.5mm,
  align: (center + top, left),
  {
    v(1.6mm)
    circle(radius: 2mm, fill: paint, stroke: none)
  },
  {
    text(size: 8.5pt, weight: 800, tracking: 1.4pt, fill: paint, upper(label))
    linebreak()
    set text(size: 12pt, weight: 500)
    as-array(lines).join(linebreak())
  },
)

// Headline that shrinks to fit the line, so long names never overflow.
#let fitted-text(body, size: 42pt, max-width: 118mm, ..style) = context {
  let candidate = text(size: size, ..style, body)
  let w = measure(candidate).width
  text(size: if w > max-width { size * (max-width / w) } else { size }, ..style, body)
}

// ══ The card ═════════════════════════════════════════════════
//  A single A5 invitation as a self-contained block. Everything is
//  positioned relative to this block rather than to the page, which
//  is what lets two of them sit side by side on one A4 sheet.
// ═════════════════════════════════════════════════════════════
#let invitation-card(
  name: "",
  age: none,
  kicker: none,
  tagline: none,
  details: (),
  rsvp: none,
  rsvp-note: none,
  palette: default-palette,
  paper: cream,
  foreground: ink,
  font: "Lato",
  lang: "en",
  divider: auto,
) = block(width: card-width, height: card-height, fill: paper, clip: true, {
  set text(font: font, fill: foreground, lang: lang)
  // Spacing is driven explicitly by v() below — the default paragraph
  // spacing scales with font size and would wreck the layout.
  set par(spacing: 0pt, leading: 0.6em)
  set block(spacing: 0pt)

  let accent = palette.at(0)
  let second = if palette.len() > 1 { palette.at(1) } else { accent }

  // Background decoration: a dense band along the top, plus a sparse
  // scattering down each side below the info card.
  confetti(seed: 1041, count: 26, y: (4mm, 44mm), palette: palette)
  confetti(seed: 2027, count: 9, y: (150mm, 202mm), x: (3mm, 22mm), palette: palette)
  confetti(seed: 3313, count: 9, y: (150mm, 202mm), x: (126mm, 145mm), palette: palette)

  // Dashed frame
  place(top + left, dx: 6mm, dy: 6mm, rect(
    width: card-width - 12mm,
    height: card-height - 12mm,
    radius: 5mm,
    fill: none,
    stroke: (paint: second, thickness: 1.2pt, dash: (4pt, 4pt)),
  ))

  let inset = 11mm
  let column = card-width - 18mm

  place(top + center, dy: inset, block(width: column, context {
    set align(center)

    // ── Build every piece before placing any of it, so the gaps can be
    //    computed from the pieces' real heights. This is what makes the
    //    card adapt to any number of detail rows.
    let kicker-piece = if kicker != none {
      text(size: 9.5pt, weight: 800, tracking: 4pt, fill: second, upper(kicker))
    }

    let name-piece = fitted-text(
      upper(name),
      size: 42pt,
      max-width: column - 12mm,
      weight: 900,
      tracking: 1pt,
      fill: accent,
    )

    let tagline-piece = if tagline != none {
      text(size: 14pt, weight: 500, fill: foreground.lighten(15%), tagline)
    }

    let divider-piece = if divider == auto {
      // Default divider: mask flanked by a dot from each palette colour.
      let dots = palette.slice(0, calc.min(4, palette.len()))
      let half = calc.max(1, int(dots.len() / 2))
      grid(
        columns: dots.len() + 1,
        column-gutter: 3mm,
        align: horizon,
        ..dots.slice(0, half).map(c => circle(radius: 1.3mm, fill: c, stroke: none)),
        carnival-mask(width: 26mm, paint: palette.at(calc.rem(3, palette.len())), eye: paper),
        ..dots.slice(half).map(c => circle(radius: 1.3mm, fill: c, stroke: none)),
      )
    } else { divider }

    let details-piece = if details.len() > 0 {
      block(
        width: column - 18mm,
        radius: 4mm,
        fill: white,
        inset: 6mm,
        stroke: 0.8pt + foreground.lighten(80%),
        {
          for (i, entry) in details.enumerate() {
            if i > 0 { v(3mm) }
            detail-row(
              entry.label,
              entry.lines,
              entry.at("color", default: palette.at(calc.rem(i, palette.len()))),
            )
          }
        },
      )
    }

    let rsvp-piece = if rsvp != none or rsvp-note != none {
      {
        if rsvp != none {
          box(
            radius: 20pt,
            fill: palette.at(calc.rem(3, palette.len())),
            inset: (x: 7mm, y: 3.2mm),
            text(size: 10.5pt, weight: 800, fill: white, tracking: 0.6pt, rsvp),
          )
        }
        if rsvp-note != none {
          v(2.5mm)
          text(size: 10pt, fill: foreground.lighten(25%), rsvp-note)
        }
      }
    }

    // ── Distribute the leftover height over the flexible gaps.
    //    Tight pairs (kicker→name, name→tagline) keep fixed spacing so
    //    the headline reads as one unit.
    let kicker-gap = 4mm
    let tagline-gap = 2mm
    let flexible = (kicker-piece, divider-piece, details-piece, rsvp-piece)
      .filter(p => p != none)
      .len()

    let height-of(piece) = if piece == none { 0mm } else {
      measure(block(width: column, piece)).height
    }
    // Parenthesised so the additions survive the line breaks — a bare
    // newline would end the expression and Typst would try to *join*
    // the terms instead of summing them.
    let fixed = (
      (kicker-piece, name-piece, tagline-piece, divider-piece, details-piece, rsvp-piece)
        .map(height-of)
        .sum()
        + (if kicker-piece != none { kicker-gap } else { 0mm })
        + (if tagline-piece != none { tagline-gap } else { 0mm })
    )

    let available = card-height - 2 * inset
    let min-gap = 3mm
    let max-gap = 9mm

    // The balloon cluster is the elastic element: it gives up height
    // first when there are many detail rows.
    let art = calc.min(48mm, calc.max(22mm, available - fixed - flexible * min-gap))
    let gap = if flexible == 0 { 0mm } else {
      calc.max(min-gap, calc.min(max-gap, (available - fixed - art) / flexible))
    }

    // ── Balloon cluster; the big one carries the age. Every dimension is
    //    a fraction of `art`, so the whole cluster scales as one unit.
    //    The big balloon reaches above the box on purpose — it is what
    //    breaks the dashed frame at the top.
    let hero-height = art * 0.708
    box(height: art, {
      place(bottom + center, dx: -art * 0.5, balloon(
        art * 0.333,
        art * 0.417,
        palette.at(calc.rem(2, palette.len())),
        string: art * 0.271,
        mirror: true,
      ))
      place(bottom + center, dx: art * 0.5, balloon(
        art * 0.292,
        art * 0.375,
        palette.at(calc.rem(3, palette.len())),
        string: art * 0.229,
      ))
      place(bottom + center, dy: -1mm, balloon(
        art * 0.583,
        hero-height,
        accent,
        string: art * 0.354,
        label: if age != none {
          text(size: hero-height * 0.32, weight: 900, fill: white, age)
        },
      ))
    })

    if kicker-piece != none {
      v(gap)
      kicker-piece
      v(kicker-gap)
    } else {
      v(gap)
    }
    name-piece
    if tagline-piece != none {
      v(tagline-gap)
      tagline-piece
    }
    for piece in (divider-piece, details-piece, rsvp-piece) {
      if piece != none {
        v(gap)
        piece
      }
    }
  }))
})

// ══ Sheet layout ═════════════════════════════════════════════
//  "a5" — one invitation per page.
//  "a4" — A4 landscape holding two identical invitations, with a cut
//         line down the seam. 2 × 148 mm = 296 mm, leaving 0.5 mm of
//         slack on each side of a 297 mm sheet.
// ═════════════════════════════════════════════════════════════
#let invitation(sheet: "a5", cut-line: true, paper: cream, ..args) = {
  let two-up = sheet == "a4"
  let card = invitation-card(paper: paper, ..args)

  set page(
    width: if two-up { 297mm } else { card-width },
    height: card-height,
    margin: 0pt,
    fill: paper,
  )

  if two-up {
    place(top + left, dx: 0.5mm, card)
    place(top + left, dx: 148.5mm, card)
    if cut-line {
      place(top + left, dx: 148.5mm, line(
        length: card-height,
        angle: 90deg,
        stroke: (paint: ink.lighten(60%), thickness: 0.4pt, dash: (2pt, 3pt)),
      ))
    }
  } else {
    card
  }
}
