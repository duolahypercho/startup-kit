# Animation

Use GSAP for high-quality animation when motion improves usability.

Official skill source: `https://github.com/greensock/gsap-skills`

## Rule

Motion must explain what changed.

Use animation for:

- State transitions.
- Focus changes.
- Progressive disclosure.
- Loading feedback.
- Scroll-linked storytelling only when the product requires it.

Avoid animation for:

- Decoration.
- Background movement.
- Delayed access to controls.
- Repeating motion that competes with work.
- Large page choreography in tool UIs.

## Agent Setup

If GSAP skills are not already installed, run:

```bash
scripts/install-gsap-skills.sh
```

The official Greensock skill repo includes guidance for GSAP core, timelines, ScrollTrigger, plugins, utilities, React, framework usage, and performance.

## Product Defaults

- Prefer opacity, transform, and height/scale transitions.
- Keep most UI motion between `120ms` and `240ms`.
- Use longer timelines only when showing a meaningful sequence.
- Respect reduced motion preferences.
- Clean up animations on unmount.
- Avoid animating layout properties when transform can express the same change.

## Performance Guardrails

- Animate only `transform` and `opacity`. Never animate `top`, `left`, `width`, or `height`.
- Never use `window.addEventListener('scroll', ...)` or read `window.scrollY` in React state for scroll-driven motion. Use ScrollTrigger, `IntersectionObserver`, or CSS scroll-driven animations.
- Isolate continuous or pointer-driven motion in its own `'use client'` leaf component and memoize it. Do not re-render the parent tree on every frame.
- Apply grain or noise only to fixed, `pointer-events-none` layers, never to scrolling containers.
- Use `will-change` sparingly, only on elements that actually animate.

## React

Use `@gsap/react` with scoped refs and cleanup. Do not target global selectors from React components.
