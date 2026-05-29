# SEO And Metadata

Every shippable product needs metadata, social cards, and error pages. Use the framework's metadata API; do not hand-write `<head>` tags ad hoc.

## Metadata

In Next.js App Router, export `metadata` (static) or `generateMetadata` (dynamic) per route.

```tsx
import type { Metadata } from "next";

export const metadata: Metadata = {
  metadataBase: new URL("https://example.com"),
  title: { default: "Acme", template: "%s · Acme" },
  description: "One sentence that says what the product does.",
  openGraph: {
    title: "Acme",
    description: "One sentence that says what the product does.",
    url: "https://example.com",
    siteName: "Acme",
    images: ["/opengraph-image"],
    type: "website",
  },
  twitter: { card: "summary_large_image" },
};
```

- Write a unique title and description per indexable page.
- Set `metadataBase` so OG and canonical URLs resolve to absolute URLs.
- Keep descriptions to one concrete sentence under ~155 characters.

## OG Images

Generate social cards with `next/og` (`ImageResponse`) at `app/opengraph-image.tsx` so they stay in sync with the theme.

- Use the kit tokens: strong text, plain background, the product name and one line.
- Keep them legible at small sizes. No dense detail.

## Required Files

- `app/icon.png` / favicon, `app/apple-icon.png`.
- `app/robots.ts` and `app/sitemap.ts` for indexable products.
- `app/manifest.ts` if the product is installable.

## Error And Empty Pages

Ship real `not-found` and `error` pages using the theme, not the framework defaults.

```tsx
// app/not-found.tsx
export default function NotFound() {
  return (
    <div className="mx-auto flex min-h-dvh max-w-md flex-col items-center justify-center gap-3 text-center px-4">
      <p className="text-strong text-lg">Page not found</p>
      <p className="text-default">The page you're looking for doesn't exist.</p>
      <Button asChild><a href="/">Go home</a></Button>
    </div>
  );
}
```

Add `app/error.tsx` (client boundary) with a retry, and `app/global-error.tsx` for root crashes. Error copy follows `references/writing.md`: what failed, how to recover, no stack traces.

## Rules

- Set canonical URLs to avoid duplicate-content splits.
- Render meaningful content server-side so crawlers see it.
- Mark up structured data (JSON-LD) only when it maps to real content (articles, products, FAQs).
