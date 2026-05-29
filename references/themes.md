# Theme Presets

The startup-kit default theme (SF Pro, quiet neutral palette) is the baseline. These presets are opt-in brand identities modeled on well-known product design systems. Use one only when a project wants that specific character; otherwise stay on the default.

All presets follow the same token contract as `assets/theme/default-theme.tokens.json`, extended with an accent and a surface ladder. The token names stay the same so the rest of the kit (forms, states, layout, dark mode) still applies.

## Presets

- `assets/theme/presets/linear.tokens.json` - disciplined dark-first. Near-black canvas, four-step surface ladder, one indigo accent, hairline borders. Inter at weight 510.
- `assets/theme/presets/vercel.tokens.json` - stark monochrome. Ink is the brand, no chromatic accent, 100px pill CTAs, deep gray scale. Geist + Geist Mono.
- `assets/theme/presets/notion.tokens.json` - warm and illustration-rich. Navy bands, pastel card tints, a single purple CTA, rectangular 8px buttons. Inter.

## When To Use Which

- Use **Linear** for dense, engineered, dark product UI where hierarchy comes from surface lift, not color.
- Use **Vercel** for developer-platform surfaces that should read as precise and monochrome.
- Use **Notion** for friendly, content-first products that want warmth and color without gradient bling.
- Use the **default** for quiet tool UI and agent skill interfaces, or when no brand has been chosen.

Use exactly one theme per project. Do not mix preset palettes.

## Fonts And Licensing

Unlike the default SF Pro stack, every preset font is openly licensed and safe to bundle:

- Inter: SIL OFL.
- Geist and Geist Mono: SIL OFL (by Vercel).

Install via the framework's font loader (for example `next/font/google` for Inter, `geist` package for Geist) rather than `<link>` tags.

## How To Apply A Preset

1. Pick the preset and read its `rules` array. They are not optional polish; they are what makes the look correct.
2. Map the preset tokens onto the shadcn CSS variables in `assets/tailwind/globals.css`:
   - `--background` from `surface.0`, elevated surfaces from `surface.1+`.
   - `--foreground` from `text.default`, headings from `text.strong`.
   - `--primary` from `accent.default`, `--ring` from `accent.default`.
   - `--border` and `--input` from `border.default`.
   - `--destructive` from `status.error`.
3. Set the font stack from the preset `font` block and load the font.
4. Set `--radius` from the preset radius scale (note the pill values: 100px for Vercel CTAs, 9999px for Linear).
5. For dark presets (Linear), apply the values under `.dark` and default the app to dark (`references/theming.md`).

## Landing Page Direction

When building a marketing or landing surface (not tool UI), the current cross-industry pattern is:

- Lead with a clear value proposition; one primary CTA above the fold.
- Put social proof (logos, stats) directly under the hero (`references/content.md` for real logos).
- Use a bento grid for features: vary tile weight instead of three identical cards.
- Default to dark mode with one saturated accent, or the chosen preset.
- Prefer interactive or real product previews over static screenshots (`references/content.md`).
- Treat performance as a feature: LCP under 2.5s, INP under 200ms; favor light motion over heavy GSAP/Three.js (`references/animation.md`).

Keep expressive backgrounds confined to these marketing surfaces (`references/backgrounds.md`), never behind dense tool UI.
