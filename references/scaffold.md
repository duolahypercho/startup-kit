# Scaffold

Use the bundled script to start a new app already wired to the startup-kit theme instead of configuring from scratch.

## Quick Start

```bash
scripts/create-app.sh my-app
cd my-app
npm run dev
```

The script creates a Next.js App Router + TypeScript + Tailwind project, replaces the global stylesheet with the kit baseline (light and dark tokens), initializes shadcn/ui with the kit `components.json`, adds the common primitives, and installs `next-themes`, `react-hook-form`, `zod`, and `lucide-react`.

## What You Get

- `src/app/globals.css` with both `:root` and `.dark` token blocks.
- shadcn/ui primitives: button, input, label, select, textarea, checkbox, switch, tabs, dialog, dropdown-menu, popover, tooltip, sheet, table, form, card, alert, skeleton, sonner.
- The SF Pro font stack (run `scripts/download-sf-pro.sh` to install the real font; see SKILL.md).

## After Scaffolding

1. Wrap the app in the theme provider (`references/theming.md`).
2. Mount `<Toaster />` once at the root (`references/states.md`).
3. Build the first screen as the primary workflow (`references/minimal-product.md`).
4. Add only the routes the product needs. Do not pre-build settings, billing, or dashboards.

## Other Stacks

The script targets Next.js because most agent product work lands there. For Vite, Remix, Astro, Vue, or Svelte:

- Copy `assets/tailwind/globals.css` (or the relevant token blocks) into the project's global stylesheet.
- Use the matching shadcn flow for the framework, keeping `cssVariables` enabled.
- Keep the same token names so the theme, dark mode, and references still apply.
