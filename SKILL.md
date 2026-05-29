---
name: startup-kit
description: Cross-agent frontend startup kit for building skill UIs and shippable products with the default SF Pro theme, light/dark Tailwind tokens, shadcn/ui conventions, and references for forms, states, accessibility, layout, copy, demo content, auth, payments, SEO, and analytics. Includes a one-command scaffold and a mechanical pre-flight quality check. Use when Codex, Claude Code, or another coding agent needs to create or update UI for agent skills, skill dashboards, or reusable frontend starter projects, or to stand up a complete product with consistent typography, colors, Tailwind configuration, shadcn/ui components, and production-launch surfaces.
---

# Startup Kit

Use this skill to build agent skill interfaces and shippable products on a minimal, precise UI baseline.

The product goal is simple: make the smallest useful product that works, then polish the details until nothing feels accidental.

Before building, state the one user, the one job, and the one primary workflow in a sentence. If the requirements are unclear, fill `assets/templates/minimal-product-brief.md` first. Build for that job, then run `references/preflight.md` before calling the work done.

## Scope

Use this kit for tool UI, skill interfaces, dashboards, and shippable products that should feel quiet, precise, and dense.

This is not the kit for expressive marketing or award-style sites. Do not import high-variance layouts, perpetual motion, bento-card systems, or glassmorphism into a tool surface. Keep expressive treatments confined to the opt-in background components on marketing, hero, and auth screens (`references/backgrounds.md`).

## Quick Start

To start a new app already wired to this theme, run `scripts/create-app.sh <app-name>` and read `references/scaffold.md`. It creates a Next.js + Tailwind + shadcn/ui project with light/dark tokens, the common primitives, and the SF Pro stack. For other stacks, copy the token blocks from `assets/tailwind/globals.css` and keep the same token names.

## Defaults

- Use SF Pro regular and medium only.
- Use `13px` as the base font size.
- Keep type sizes to `12px`, `13px`, `14px`, `16px`, `18px`, and `24px`.
- Use `24px` as the largest UI text size.
- Use the bundled theme assets as the source of truth:
  - `assets/theme/default-theme.css`
  - `assets/theme/default-theme.tokens.json`
  - `assets/theme/dark-theme.css`
  - `assets/theme/dark-theme.tokens.json`
  - `assets/tailwind/tailwind.config.ts`
  - `assets/tailwind/globals.css`
  - `assets/shadcn/components.json`
  - `assets/shadcn/components.tailwind-v3.json`
  - `assets/icons/lucide/`
  - `assets/icons/simple-icons/`
  - `assets/icons/tabler/`
  - `assets/components/backgrounds/`
  - `assets/templates/`

## Font

Use the real SF Pro font when the target environment can legally install it.

1. Run `scripts/download-sf-pro.sh` to download Apple's official SF Pro installer into `assets/fonts/vendor/`.
2. Do not commit extracted `.otf` files or redistribute Apple font files unless the project has confirmed license rights.
3. In generated CSS, prefer the bundled font stack:

```css
font-family: "SF Pro", "SF Pro Text", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
```

## Tailwind And Shadcn

Read `references/tailwind-shadcn.md` before creating or changing Tailwind, shadcn/ui, or component code.

Use shadcn/ui for all standard components: buttons, inputs, selects, dialogs, popovers, tabs, menus, tables, forms, labels, switches, checkboxes, tooltips, sheets, alerts, and cards.

Only create a custom component when shadcn/ui does not provide the needed primitive or when composing shadcn primitives into a domain-specific component.

When initializing shadcn/ui, use `assets/shadcn/components.json` for Tailwind CSS v4 projects or `assets/shadcn/components.tailwind-v3.json` for Tailwind CSS v3 projects. Keep `cssVariables` enabled.

## Dark Mode

Read `references/theming.md` before adding dark mode or changing color tokens.

The kit ships both schemes in one token contract. `assets/tailwind/globals.css` includes `:root` (light) and `.dark` blocks; `assets/theme/dark-theme.tokens.json` and `assets/theme/dark-theme.css` mirror the light tokens. Use class-based dark mode with `next-themes`, default to `system`, and switch token values, never token names.

## Layout And Spacing

Read `references/layout.md` before structuring pages, app shells, or grids.

Use the Tailwind 4px spacing scale, mobile-first breakpoints, and the bundled app-shell pattern. Align edges exactly, keep one rhythm per surface, and keep tool UI dense.

## Icons

Use Lucide as the default UI icon library.

Read `references/icons.md` before adding icon dependencies, choosing brand icons, or creating custom SVGs.

Use icons from `lucide-react` in React/shadcn projects. Use the bundled SVG starter set in `assets/icons/lucide/` for static templates, documentation, non-React targets, or agents that need local icon assets.

Use Simple Icons only for brand logos. Use Tabler only as a fallback when Lucide does not include the needed UI concept.

## Animation

Use the official Greensock GSAP skills for high-quality animation work: `https://github.com/greensock/gsap-skills`.

Read `references/animation.md` before adding animation. Install the official GSAP skills with `scripts/install-gsap-skills.sh` when the current agent environment does not already provide them.

Use animation only to clarify continuity, focus, feedback, or state change. Do not add motion as decoration.

## Backgrounds

Use bundled background components only as opt-in expressive surfaces for marketing, hero, auth, and splash screens. Do not put animated backgrounds behind dense tool UI.

Read `references/backgrounds.md` before adding a background component.

Use `assets/components/backgrounds/manifest.json` to see the approved set — 42 React Bits components (fluid, aurora, plasma, particle, grid, glitch, and 3D effects). Most are transparent WebGL canvases that fill their parent, so wrap them in a positioned element with an explicit height. Dependencies vary by component (`ogl`, `three`, `@react-three/fiber`/`@react-three/drei`, `postprocessing`, `face-api.js`, `gsap`, or none); the manifest's `dependencyGroups` lists what to install for each. Copy the matching `.jsx` and `.css` files together into the target app (three components — `Silk`, `Ballpit`, `LetterGlitch` — ship without CSS) and render the background behind content. Keep text contrast intact, use at most one expressive background per view, prefer the lighter options for long-lived surfaces, and provide a static fallback when `prefers-reduced-motion` is set.

## Forms

Read `references/forms.md` before building any form.

Build forms with shadcn/ui `Form` on `react-hook-form` and `zod`. Use real labels, inline validation, one primary action, a disabled-while-submitting button, and server errors mapped back to fields.

## States And Feedback

Read `references/states.md` before building flows that load, mutate, or can fail.

Provide explicit empty, loading, error, success, and disabled states. Use skeletons shaped like the content, `sonner` toasts for transient feedback, and `Alert` for section-level errors with a retry. Never show raw errors to users.

## Accessibility

Read `references/accessibility.md` and treat it as part of the quality bar.

Every action works with a keyboard, every control has an accessible name, color meets AA contrast, and async results are announced. shadcn/ui (Radix) gives correct semantics by default; do not break them.

## Writing

Read `references/writing.md` before writing UI copy.

Use plain, direct, sentence-case copy. Name results on buttons, name objects on labels, and write real empty, error, and success messages. Remove placeholder copy before finishing.

## Demo Content

Read `references/content.md` before writing example data, empty states, or social proof.

Use realistic, specific content even in examples. No generic names ("John Doe"), slop brand names ("Acme"), fake-perfect numbers (`99.99%`), text-only logo walls, `<div>`-based fake screenshots, or em dashes. Use the bundled Simple Icons for real brand logos.

## Auth, Payments, And Launch Surfaces

These references apply when building a shippable product rather than a single skill UI.

- `references/auth.md`: use a managed auth provider; protect routes on the server; never store tokens in `localStorage`.
- `references/payments.md`: use Stripe; let it own card data and checkout; treat the webhook as the source of truth for entitlements.
- `references/seo.md`: set per-route metadata, OG images via `next/og`, and real `not-found`/`error` pages using the theme.
- `references/analytics.md`: pick one privacy-respecting tool and instrument the primary workflow, not every click.
- `references/legal.md`: ship a privacy policy and terms; start from `assets/templates/privacy-policy.md` and `assets/templates/terms-of-service.md` and have counsel review.

## Minimal Product Standard

Read `references/minimal-product.md` before designing screens, app flows, or templates.

Use `assets/templates/minimal-product-brief.md` when the product requirements are unclear.

Default to one primary workflow, one clear empty state, one clear error state, and one direct success state. Remove every section, option, visual, and word that does not help the user finish the job.

## Pre-Flight Check

Run `references/preflight.md` before declaring any UI done. It is a binary, tickable gate covering brief, theme, components, states, layout, accessibility, content, and engineering. If one item cannot be honestly ticked, the work is not finished.

## Implementation Rules

- Copy or adapt the asset files into the target app rather than inventing new tokens.
- Verify every imported package is in `package.json` before using it; output the install command when it is missing.
- Keep components quiet, dense, and tool-like.
- Prefer one obvious path through the product.
- Choose fewer controls and make each one exact.
- Treat spacing, alignment, labels, and disabled states as product behavior, not decoration.
- Use text colors by intent: subtle `#7f7f7f`, default `#5d5d5d`, strong `#292929` (light); subtle `#8a8a8a`, default `#a1a1a1`, strong `#f5f5f5` (dark).
- Use selected backgrounds as `#f5f5f5` (light) or `#1a1a1a` (dark).
- Use borders as `#f2f2f2` (light) or `#1f1f1f` (dark).
- Pull color through tokens so light and dark stay in sync; do not hardcode hex in components.
- Avoid larger display typography, extra font weights, gradients, decorative shadows, or broad palettes unless the target project explicitly overrides this theme.
