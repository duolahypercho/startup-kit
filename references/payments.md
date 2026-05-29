# Payments

Use Stripe for payments and subscriptions. Let Stripe own the card data and the checkout surface; your app owns the entitlement.

## Setup

```bash
npm install stripe @stripe/stripe-js
```

Keep keys in environment variables. The publishable key is client-safe; the secret key and webhook secret are server-only and must never reach the client.

## Flow

1. Define products and prices in the Stripe dashboard, not in code.
2. Create a Checkout Session on the server and redirect to it (hosted checkout) or mount Embedded Checkout.
3. Stripe handles card entry, 3DS, and receipts.
4. A webhook is the source of truth for what the user is entitled to. Do not grant access on the client redirect alone.

```ts
// server: create checkout session
const session = await stripe.checkout.sessions.create({
  mode: "subscription",
  line_items: [{ price: priceId, quantity: 1 }],
  success_url: `${origin}/billing?status=success`,
  cancel_url: `${origin}/billing?status=cancelled`,
  customer: stripeCustomerId,
});
return Response.json({ url: session.url });
```

## Webhooks

- Verify the signature with the webhook secret before trusting any event.
- Handle `checkout.session.completed`, `customer.subscription.updated`, and `customer.subscription.deleted` at minimum.
- Make handlers idempotent; Stripe retries.
- Update your own `subscription`/`entitlement` record from the webhook, then gate features on that record.

```ts
const event = stripe.webhooks.constructEvent(rawBody, sig, webhookSecret);
```

## Billing UI

- Use the Stripe Customer Portal for plan changes, payment methods, and invoices instead of building them.
- In-app, show the current plan, what it includes, and one action ("Manage billing" → portal, or "Upgrade" → checkout).
- Gate premium features on the stored entitlement, and show a clear, honest upgrade prompt when a user hits a limit.

## Rules

- Never log or store full card numbers; you should never see them.
- Test with Stripe test mode and the CLI (`stripe listen`) before going live.
- Handle failed payments and past-due states; show the user how to fix billing.
- Prices and currency are locale-formatted (`references/writing.md`).
