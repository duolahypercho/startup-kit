# Pre-Flight Check

Run this before declaring any UI done. Each item is binary. If one cannot be honestly ticked, the work is not finished.

This is the startup-kit quality gate. It enforces the rules in the other references mechanically, not by feeling.

## Brief

- [ ] The one user, one job, and one primary workflow are stated (`references/minimal-product.md`).
- [ ] Every section, control, and word on screen helps finish that job. Anything else is removed.

## Theme

- [ ] All color comes from tokens, not hardcoded hex (`references/theming.md`).
- [ ] Type sizes are only `12 / 13 / 14 / 16 / 18 / 24px`; base is `13px`; nothing larger than `24px`.
- [ ] Font weights are only regular (400) and medium (500).
- [ ] No gradients, decorative shadows, or display typography unless the project explicitly overrides the theme.
- [ ] Tested in both light and dark mode.

## Components

- [ ] Standard controls come from shadcn/ui, not hand-rolled markup (`references/tailwind-shadcn.md`).
- [ ] Icons come from Lucide, except brand logos (Simple Icons) (`references/icons.md`).
- [ ] Forms use shadcn `Form` + react-hook-form + zod, labels above inputs (`references/forms.md`).

## States

- [ ] Empty, loading, error, success, and disabled states exist for every flow that loads, mutates, or can fail (`references/states.md`).
- [ ] Loading uses skeletons shaped like the content; layout does not shift when data arrives.
- [ ] Errors say what failed and how to recover. No raw codes or stack traces shown to users.

## Layout

- [ ] Edges align; spacing uses the 4px scale; one rhythm per surface (`references/layout.md`).
- [ ] Multi-column layouts declare their single-column fallback below `md`.
- [ ] One primary action per screen.

## Accessibility

- [ ] Every action works with a keyboard and has a visible focus ring (`references/accessibility.md`).
- [ ] Every control has an accessible name; icon-only buttons have a label and tooltip.
- [ ] Text and UI affordances meet WCAG AA contrast in both modes.
- [ ] Motion and backgrounds respect `prefers-reduced-motion`.

## Content

- [ ] No placeholder or lorem copy remains (`references/content.md`).
- [ ] No generic names ("John Doe"), slop brand names ("Acme"), or fake-perfect numbers (`99.99%`).
- [ ] No em dash anywhere in visible copy.
- [ ] No `<div>`-based fake screenshots.

## Engineering

- [ ] Every imported package is present in `package.json` or installed.
- [ ] Animations target only `transform` and `opacity`; no scroll-event listeners; cleanup on unmount (`references/animation.md`).
