# Tailwind And Shadcn Reference

## Tailwind Theme

Use `assets/tailwind/tailwind.config.ts` as the baseline config. It maps the default startup-kit tokens into Tailwind names:

- `font-sans`: SF Pro stack
- `text-xs`: `12px`
- `text-sm`: `13px`
- `text-base`: `13px`
- `text-md`: `14px`
- `text-lg`: `16px`
- `text-xl`: `18px`
- `text-2xl`: `24px`
- `text-subtle`: `#7f7f7f`
- `text-default`: `#5d5d5d`
- `text-strong`: `#292929`
- `bg-selected`: `#f5f5f5`
- `border-default`: `#f2f2f2`

Keep Tailwind class usage literal and predictable. Do not introduce one-off arbitrary values for theme colors or font sizes.

For Tailwind CSS v4 projects, keep `tailwind.config` blank in `components.json`, then keep the same token names in CSS using `@theme` and shadcn's CSS variable flow. For Tailwind CSS v3 projects, use the bundled `tailwind.config.ts` and `components.tailwind-v3.json`.

## Shadcn/ui

Initialize shadcn/ui in the target app when it is not already installed:

```bash
npx shadcn@latest init
```

Use `assets/shadcn/components.json` as the Tailwind CSS v4 baseline:

- `style`: `new-york`
- `baseColor`: `neutral`
- `cssVariables`: `true`
- empty `tailwind.config`
- aliases for `components`, `utils`, `ui`, `lib`, and `hooks`

Use `assets/shadcn/components.tailwind-v3.json` when the target project still uses `tailwind.config.ts`.

Add primitives as needed:

```bash
npx shadcn@latest add button input label select textarea checkbox switch tabs dialog dropdown-menu popover tooltip sheet table form card alert
```

Use shadcn/ui for standard controls instead of hand-rolled markup. Compose primitives locally for product-specific workflows.

## CSS Variables

Use `assets/tailwind/globals.css` as the shadcn-compatible global stylesheet. It keeps shadcn's required CSS variable structure while binding the visible UI to the startup-kit palette.

Prefer semantic component classes from shadcn/ui, then override with the startup-kit token names only when the default component output needs alignment.
