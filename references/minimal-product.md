# Minimal Product

Build the smallest useful product that works, then remove anything unnecessary.

## Product Rule

Start with one user, one job, one primary workflow, one success state, one error state, and one empty state.

Do not add dashboards, onboarding, filters, charts, settings, billing, or profile surfaces unless the current task requires them.

If two solutions work, choose the one with fewer screens, fewer controls, fewer words, and fewer states.

## Screen Rules

- Put the primary workflow on the first screen.
- Use one primary action per screen.
- Keep navigation shallow.
- Prefer inline controls over modal flows when the task is simple.
- Use tables only when comparison matters.
- Use cards only for repeated items, not as page wrappers.
- Keep body copy short and concrete.
- Show what changed after every action.
- Align edges exactly.
- Keep spacing consistent.
- Remove placeholder copy before finishing.
- Prefer labels that name the object over labels that explain the interface.

## Working States

Every product flow needs:

- Empty state: what the user can do next.
- Loading state: what is happening now.
- Error state: what failed and how to recover.
- Success state: what completed and what is now available.
- Disabled state: why the action is unavailable when it is not obvious.

## Quality Bar

Before considering the UI done, verify:

- The core action can be completed.
- Inputs have labels.
- Buttons use action verbs.
- Text fits at mobile and desktop widths.
- The UI uses the startup-kit theme tokens.
- Standard controls come from shadcn/ui.
- Icons come from Lucide unless they are brand logos.
- There are no decorative gradients, oversized headings, or unused sections.
- Every visible element earns its place.
