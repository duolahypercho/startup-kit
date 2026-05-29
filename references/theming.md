# Theming And Dark Mode

Use the bundled token sets as the source of truth for both color schemes:

- `assets/theme/default-theme.tokens.json` (light)
- `assets/theme/dark-theme.tokens.json` (dark)
- `assets/tailwind/globals.css` ships both `:root` (light) and `.dark` blocks.

## Rule

Keep one token contract across both schemes. Switch values, never names.

Every color the UI shows must come from a token. Do not hardcode hex values in components when a token exists.

## Default Palettes

Light text on white:

- subtle `#7f7f7f`, default `#5d5d5d`, strong `#292929`
- selected `#f5f5f5`, border `#f2f2f2`

Dark text on `#0a0a0a`:

- subtle `#8a8a8a`, default `#a1a1a1`, strong `#f5f5f5`
- selected `#1a1a1a`, border `#1f1f1f`

## Enabling Dark Mode

Use class-based dark mode so the scheme is controllable, not just system-driven.

1. Keep `darkMode: ["class"]` in `tailwind.config.ts` (Tailwind v3) or `@custom-variant dark (&:is(.dark *))` in CSS (Tailwind v4).
2. Toggle the `dark` class on `<html>`.
3. In React, use `next-themes` to persist the choice and avoid a flash:

```bash
npm install next-themes
```

```tsx
import { ThemeProvider } from "next-themes";

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
      {children}
    </ThemeProvider>
  );
}
```

## Product Defaults

- Default to `system` so the product matches the user's OS.
- Test contrast in both schemes. Strong text must stay strong; subtle must stay readable.
- Set `color-scheme` so native controls (scrollbars, inputs) match.
- Avoid pure black surfaces and pure white text in dark mode; the bundled tokens already pull both inward.
- Theme one expressive background per view, not the whole app, and keep it legible in both schemes.
