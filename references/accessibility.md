# Accessibility

Accessibility is part of the quality bar, not an add-on. shadcn/ui (Radix) gives correct semantics by default; the job is to not break them.

## Rule

Every action works with a keyboard, every control has an accessible name, and every state is announced.

## Keyboard

- All interactive elements reach focus in a logical order. Do not set `tabindex` above `0`.
- Visible focus ring on every focusable element. Never remove `outline` without a replacement (`focus-visible:ring-2 focus-visible:ring-ring`).
- `Esc` closes dialogs, popovers, and sheets. `Enter`/`Space` activate buttons.
- Trap focus inside modals; return focus to the trigger on close. Radix dialogs do this already.

## Names And Roles

- Use a real `<button>` for actions and `<a href>` for navigation. Do not put `onClick` on a `<div>`.
- Icon-only buttons need `aria-label` and a tooltip.
- Form controls use a `<label>` (shadcn `FormLabel` ties it for you).
- Decorative icons get `aria-hidden="true"`; meaningful icons get a label.
- Group related controls with `fieldset`/`legend` or `role="group"` plus a label.

## Contrast

- Body and UI text meet WCAG AA: 4.5:1 normal, 3:1 for large text and UI affordances.
- The bundled tokens pass on their default surfaces. Re-check when placing text over backgrounds or selected rows.
- Do not signal state with color alone. Pair color with an icon, text, or shape.

## Motion And Media

- Respect `prefers-reduced-motion`; render static fallbacks for animation and backgrounds.
- Provide `alt` text for informative images; empty `alt=""` for decorative ones.
- Caption or transcribe meaningful audio/video.

## Live Regions

- Announce async results (toast, validation, save state) via an `aria-live` region. Sonner handles this; custom status text needs `role="status"` or `aria-live="polite"`.
- Announce errors with `aria-live="assertive"` only when they interrupt the task.

## Verify

- Tab through the whole flow with no mouse.
- Zoom to 200% and confirm nothing is cut off or overlapping.
- Run an automated pass (axe DevTools or Lighthouse) and fix violations.
- Test one full flow with a screen reader (VoiceOver on macOS) before calling a feature done.
