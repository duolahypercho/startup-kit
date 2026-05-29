# Icons

Use Lucide as the primary UI icon library.

Use this order:

1. Lucide for product UI icons.
2. Simple Icons for brand logos.
3. Tabler only when Lucide does not have the needed UI concept.

## Defaults

- Use `lucide-react` for React and shadcn/ui projects.
- Use the matching official Lucide package for Vue, Svelte, Angular, Astro, React Native, or static SVG output.
- Keep icons at `16px` or `18px` in dense UI. Use `20px` only for larger controls.
- Use `stroke-width="2"` and `currentColor`.
- Keep labels visible for ambiguous actions. Icon-only buttons need tooltips.

## Bundled Starter Icons

Use `assets/icons/lucide/manifest.json` to see the approved local SVG starter set.

The starter set covers common agent UI states:

- run/start
- settings
- terminal
- file/artifact
- success
- warning
- loading
- download
- bot/agent
- sidebar
- search
- add
- close
- command
- database

Use `assets/icons/simple-icons/manifest.json` for bundled brand logo SVGs.

Use `assets/icons/tabler/manifest.json` for bundled fallback UI SVGs.

## Other Libraries

- Use Simple Icons only for brand logos. Check each brand/legal disclaimer before use.
- Use Tabler only when Lucide does not have the needed concept.
- Use Iconify only as a search surface. Check the selected icon set license before copying icons.

Do not mix icon families in the same UI unless a product requirement forces it.
