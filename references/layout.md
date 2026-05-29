# Layout And Spacing

Layout is product behavior. Consistent spacing, alignment, and structure make the UI feel deliberate.

## Spacing Scale

Use the Tailwind 4px scale. Do not invent arbitrary spacing.

- `1` = 4px, `2` = 8px, `3` = 12px, `4` = 16px, `6` = 24px, `8` = 32px, `12` = 48px, `16` = 64px.
- Use `2`/`3` inside controls, `4`/`6` between related groups, `8`+ between sections.
- Pick one rhythm per surface and keep it. Mixed gaps read as accidental.

## Breakpoints

Use Tailwind defaults. Design mobile-first, then add `md`/`lg`.

- `sm` 640, `md` 768, `lg` 1024, `xl` 1280, `2xl` 1536.
- Single column by default; introduce columns at `md` and up.
- Collapse the sidebar into a `Sheet` below `md`.

## Page Structure

- Constrain reading content with `max-w-2xl`/`max-w-3xl`; constrain app shells with `max-w-screen-xl`.
- Use a consistent page padding: `px-4 md:px-6 lg:px-8`.
- Keep one primary action visible per screen, top-right or bottom of the primary flow.
- Align edges exactly. Controls in a row share a baseline; cards in a grid share widths.

## App Shell

A standard tool layout: fixed topbar, collapsible sidebar, scrollable content.

```tsx
export function AppShell({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex h-dvh flex-col">
      <header className="flex h-12 items-center gap-3 border-b px-4">
        {/* logo, search, account */}
      </header>
      <div className="flex min-h-0 flex-1">
        <aside className="hidden w-56 shrink-0 border-r md:block">
          {/* nav */}
        </aside>
        <main className="min-w-0 flex-1 overflow-y-auto px-4 py-6 md:px-6">
          {children}
        </main>
      </div>
    </div>
  );
}
```

## Grids

- Use `grid` with `gap-4`/`gap-6` for card collections; let columns wrap with `auto-fill`/`minmax`.
- Use cards only for repeated items, never as a page wrapper.
- Use tables (shadcn `Table`) when comparison across rows matters; use lists otherwise.

## Density

- Keep tool UI dense and quiet: 8–12px vertical padding in rows, 12px base text.
- Add breathing room (24px+) only on marketing, auth, and empty surfaces.
- Do not center everything. Left-align scannable content; reserve centering for empty states and single-focus screens.
