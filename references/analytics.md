# Analytics

Measure whether the product does its one job. Track the primary workflow, not everything.

## Choosing A Tool

- Default to a privacy-respecting, lightweight product analytics tool: Vercel Analytics, PostHog, or Plausible.
- Use one tool. Two analytics scripts double the weight and split the data.
- Add error monitoring (Sentry) separately from product analytics; they answer different questions.

## What To Track

Start from the minimal-product flow and instrument its spine:

- The primary action started and completed (e.g. `project_created`).
- Drop-off points in multi-step flows.
- Sign-up and activation.
- Errors that block the workflow.

Do not track every click. Noise hides the signal.

## Event Conventions

- Name events `object_action` in past tense: `invoice_sent`, `file_uploaded`.
- Keep a small, documented set of properties per event; reuse property names across events.
- Identify users by a stable id after auth; keep anonymous sessions before.

```ts
analytics.capture("project_created", { plan: "free", template: "blank" });
```

## Privacy

- Don't send PII (emails, names, tokens) as event properties.
- Respect Do Not Track and consent where required; gate non-essential analytics behind consent.
- Anonymize IPs where the tool supports it.
- Document what you collect; keep it honest (`references/legal.md`).

## Performance

- Load analytics scripts with `afterInteractive`/deferred strategy so they never block first paint.
- Keep total third-party JS small; analytics should not regress Core Web Vitals.

## Rules

- Verify events fire in a staging environment before launch.
- Tie one metric to the product's job and watch it; vanity metrics don't tell you if it works.
