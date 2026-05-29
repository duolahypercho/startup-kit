# Scaffold

Use the bundled script to start a new app already wired to the startup-kit theme instead of configuring from scratch.

Scaffolding is the step *after* onboarding. Run `references/onboarding.md` first; `create-app.sh` refuses to run until onboarding has written `.startup-kit/intake.md` (override with `--skip-onboarding` only when you deliberately want raw scaffolding). See the STOP gate in `SKILL.md`.

## Quick Start

```bash
scripts/create-app.sh my-app    # requires .startup-kit/intake.md (run onboarding first)
cd my-app
npm run dev
```

The script creates a Next.js App Router + TypeScript + Tailwind project, replaces the global stylesheet with the kit baseline (light and dark tokens), initializes shadcn/ui with the kit `components.json`, adds the common primitives, and installs `next-themes`, `react-hook-form`, `zod`, and `lucide-react`.

## What You Get

- `src/app/globals.css` with both `:root` and `.dark` token blocks.
- shadcn/ui primitives: button, input, label, select, textarea, checkbox, switch, tabs, dialog, dropdown-menu, popover, tooltip, sheet, table, form, card, alert, skeleton, sonner.
- The SF Pro font stack (run `scripts/download-sf-pro.sh` to install the real font; see SKILL.md).
- The animated/3D background catalog in `src/components/backgrounds/` plus the `animated-background.tsx` wrapper, with `three` and `ogl` installed. Wire one onto the landing/hero by default (`references/backgrounds.md`); add a heavier one with `scripts/add-background.sh <Name>`.

## After Scaffolding

1. Wrap the app in the theme provider (`references/theming.md`).
2. Mount `<Toaster />` once at the root (`references/states.md`).
3. Build the first screen as the primary workflow (`references/minimal-product.md`).
4. Add only the routes the product needs. Do not pre-build settings, billing, or dashboards.
5. If the product has a landing/marketing/hero surface, wire one bundled background into it with `AnimatedBackground` (`references/backgrounds.md`). Keep dense tool UI flat.

## Other Stacks

The script targets Next.js because most agent product work lands there. For Vite, Remix, Astro, Vue, or Svelte:

- Copy `assets/tailwind/globals.css` (or the relevant token blocks) into the project's global stylesheet.
- Use the matching shadcn flow for the framework, keeping `cssVariables` enabled.
- Keep the same token names so the theme, dark mode, and references still apply.
