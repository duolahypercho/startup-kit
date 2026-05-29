# Authentication

Use a managed auth provider. Do not hand-roll session handling, password hashing, or token storage for a new product.

## Choosing A Provider

- Default to a hosted provider: Clerk, Auth0, or Supabase Auth for full-featured needs; Auth.js (NextAuth) when you want to own the routes.
- Pick one and commit. Mixing providers fragments the session model.
- Use OAuth (Google, GitHub) plus email as the default set. Add magic links before passwords when you can.

## Screens

Auth screens are a marketing-adjacent surface, so they may use more space and an optional expressive background (`references/backgrounds.md`). Keep the form itself quiet and tool-like.

Standard set:

- Sign in
- Sign up
- Forgot password / reset
- Verify email
- (optional) Accept invite

Build the form with the patterns in `references/forms.md`: real labels, inline validation, a single primary action, disabled-while-submitting button, server errors mapped back to fields.

```tsx
<div className="mx-auto flex min-h-dvh w-full max-w-sm flex-col justify-center gap-6 px-4">
  <div className="space-y-1 text-center">
    <h1 className="text-xl text-strong">Sign in</h1>
    <p className="text-default">Welcome back.</p>
  </div>
  {/* OAuth buttons, divider, email form */}
</div>
```

## Route Protection

- Protect routes in middleware, not just in the client. Client checks are UX, server checks are security.
- Redirect unauthenticated users to sign-in with a `redirect` back to where they were headed.
- Read the session on the server for protected pages; never trust a client-only flag.

## Rules

- Never store secrets, tokens, or passwords in `localStorage`. Use the provider's secure, httpOnly session cookies.
- Keep API keys and provider secrets in environment variables (`references/env.md` if present; otherwise the provider's `.env` guidance). Never commit them.
- Show a clear signed-in state and an obvious sign-out.
- Handle the loading state of the session so protected UI doesn't flash.

## Product Defaults

- Send users to the primary workflow after sign-in, not to a generic dashboard.
- Keep sign-up to the minimum fields needed to start. Collect the rest in context later.
- Make password reset and email verification real flows, not dead links.
