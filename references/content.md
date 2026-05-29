# Demo Content

The data an agent invents is part of the product. Generic placeholder content is the clearest sign a UI was generated, not designed. Use realistic, specific content even in examples and empty states.

## Rule

Write content a real user could have created. Never ship filler that announces itself as filler.

## Names And People

- Do not use "John Doe", "Jane Doe", "Sarah Chan", "Jack Su", or other defaults.
- Use varied, realistic, locale-appropriate names. Mix first/last origins so a list does not read as one template.
- Do not use the generic egg avatar or a Lucide user glyph for every person. Use initials in a tinted circle, a real photo placeholder, or a deterministic generated avatar keyed to the name.

## Numbers And Data

- Avoid fake-perfect figures: `99.99%`, `50%`, `1,234,567`, `+1 (123) 456-7890`.
- Use organic, slightly messy values: `47.2%`, `1,284`, `+1 (312) 847-1928`.
- Only show precision the product actually has. Do not fabricate engineering-grade specs the app does not produce.
- Format numbers, currency, and dates with `Intl` (see `references/writing.md`). Always show units.

## Brand And Product Names

- Do not use "Acme", "Nexus", "SmartFlow", "Cloudly", or other startup-slop names in examples.
- Invent a contextual, plausible name that fits the domain, or use the real project name when known.

## Logos And Social Proof

- For "trusted by" / brand rows, use real logos, not text wordmarks in a `<span>`.
- Use the bundled brand SVGs in `assets/icons/simple-icons/` (Simple Icons). Check each brand's usage terms before shipping.
- For an invented brand, render a simple monogram SVG that matches the theme, not plain text.
- Keep logos legible in both light and dark mode.

## Screenshots And Previews

- Do not build fake product UI out of `<div>` rectangles to fake a screenshot.
- Show a real component (a small live instance of the actual UI), a real screenshot, or nothing.
- For marketing or auth surfaces that need imagery, use a generated image or a seeded placeholder (`https://picsum.photos/seed/<descriptive-seed>/<w>/<h>`), not broken or random links.

## Copy

- Remove all lorem ipsum and `TODO` placeholder strings before finishing.
- Write real empty, error, and success copy, not "No data" and "Error".
- Do not use the em dash (`-` is fine). It is the most common generated-copy tell. Restructure with a comma, period, or colon.
- Avoid filler verbs: "Elevate", "Seamless", "Unleash", "Next-Gen", "Revolutionize". Name the concrete action instead.
