# States And Feedback

Every flow that loads, mutates, or can fail needs explicit states. The minimal-product standard requires empty, loading, error, success, and disabled. This reference says how to build them.

## Setup

```bash
npx shadcn@latest add skeleton sonner alert
```

Mount the toaster once at the app root:

```tsx
import { Toaster } from "@/components/ui/sonner";

<body>
  {children}
  <Toaster />
</body>
```

## Loading

Use skeletons that match the shape of the content, not spinners, for first loads.

- Use a skeleton that mirrors the final layout (same rows, same widths).
- Use an inline spinner only for in-place actions (button submit, row refresh).
- Show optimistic UI for fast, reversible mutations; reconcile on response.
- Never shift layout when content arrives.

```tsx
import { Skeleton } from "@/components/ui/skeleton";

export function RowSkeleton() {
  return (
    <div className="flex items-center gap-3 py-2">
      <Skeleton className="h-8 w-8 rounded-full" />
      <Skeleton className="h-3 w-40" />
    </div>
  );
}
```

## Empty

An empty state tells the user what they can do next, not just that there is nothing.

- One sentence of context, one primary action.
- Use the same primary action the populated view uses.
- No illustrations in dense tool UI; keep it quiet.

```tsx
<div className="flex flex-col items-center gap-3 py-12 text-center">
  <p className="text-default">No projects yet.</p>
  <Button>Create your first project</Button>
</div>
```

## Error

Say what failed and how to recover. Never show a raw stack trace or a bare "Error".

- Inline field errors for form input (see `references/forms.md`).
- `Alert` with `variant="destructive"` for section-level failures with a retry.
- Toast for transient action failures.
- A full-page error boundary for unexpected crashes (see SEO/metadata for the error page).

```tsx
<Alert variant="destructive">
  <AlertTitle>Couldn't load projects</AlertTitle>
  <AlertDescription>Check your connection and try again.</AlertDescription>
  <Button variant="outline" size="sm" onClick={retry}>Retry</Button>
</Alert>
```

## Success

Confirm what completed and what is now available. Prefer showing the changed object over a generic "Saved".

- Toast for background or list mutations.
- Inline state change (a row updates, a badge flips) when the result is on screen.
- Redirect to the new object after creation, not back to an empty form.

```tsx
import { toast } from "sonner";

toast.success("Project created", {
  action: { label: "Open", onClick: () => router.push(`/projects/${id}`) },
});
```

## Disabled

Disable an action only when it cannot succeed, and make the reason obvious.

- Add a tooltip when the reason is not visible on screen.
- Prefer guiding the user to enable the action over silently disabling it.
- Do not disable a primary action without explanation.

## Product Defaults

- Reserve space for state changes so nothing jumps.
- One toast per action. Do not stack duplicate toasts.
- Keep toast copy under a line; put detail in the destination, not the toast.
- Respect reduced motion in any state transition.
