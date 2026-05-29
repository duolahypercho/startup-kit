# Backgrounds

Use bundled background components only as opt-in expressive surfaces. They are not part of the default quiet, tool-like UI.

Source: React Bits (`https://reactbits.dev`)

## Rule

A background must support the content, not compete with it.

Use an animated background only for:

- Marketing and landing surfaces.
- Hero sections.
- Auth, splash, and onboarding screens.
- Empty states that need a single moment of personality.

Avoid an animated background for:

- Dense tool UI, tables, forms, and dashboards.
- Any surface where text must stay highly legible.
- Long-running views that keep the GPU busy without purpose.

## Bundled Backgrounds

Use `assets/components/backgrounds/manifest.json` to see the approved set.

### LiquidEther

A WebGL fluid simulation that reacts to pointer movement and idles with an auto-demo. The canvas is transparent, so it sits behind foreground content.

- Files: `assets/components/backgrounds/LiquidEther.jsx`, `assets/components/backgrounds/LiquidEther.css`
- Framework: React
- Dependency: `three`

Install the dependency:

```bash
npm install three
```

Copy both files into the target app, keep them next to each other so the relative `./LiquidEther.css` import resolves, then render it behind content with absolute positioning:

```jsx
import LiquidEther from './LiquidEther';

<div style={{ position: 'relative', isolation: 'isolate' }}>
  <div style={{ position: 'absolute', inset: 0, zIndex: 0 }}>
    <LiquidEther
      colors={['#5227FF', '#FF9FFC', '#B497CF']}
      mouseForce={20}
      cursorSize={100}
      resolution={0.5}
      autoDemo
      autoSpeed={0.5}
      autoIntensity={2.2}
    />
  </div>
  <div style={{ position: 'relative', zIndex: 1 }}>{/* content */}</div>
</div>;
```

The root container fills its parent, so the wrapper must have an explicit height.

### Prism

A WebGL ray-marched prism with glow, bloom, and film grain. The canvas is transparent, so it sits behind foreground content.

- Files: `assets/components/backgrounds/Prism.jsx`, `assets/components/backgrounds/Prism.css`
- Framework: React
- Dependency: `ogl`

Install the dependency:

```bash
npm install ogl
```

Copy both files into the target app, keep them next to each other so the relative `./Prism.css` import resolves, then render it behind content with absolute positioning:

```jsx
import Prism from './Prism';

<div style={{ position: 'relative', isolation: 'isolate' }}>
  <div style={{ position: 'absolute', inset: 0, zIndex: 0 }}>
    <Prism
      animationType="rotate"
      timeScale={0.5}
      height={3.5}
      baseWidth={5.5}
      scale={3.6}
      hueShift={0}
      colorFrequency={1}
      noise={0.5}
      glow={1}
    />
  </div>
  <div style={{ position: 'relative', zIndex: 1 }}>{/* content */}</div>
</div>;
```

Choose `animationType` by intent: `rotate` for a calm idle shimmer, `hover` for pointer-reactive tilt, `3drotate` for a continuous spin. Set `suspendWhenOffscreen` to pause rendering when the element scrolls out of view. The root container fills its parent, so the wrapper must have an explicit height.

## Full Catalog

Every background lives in `assets/components/backgrounds/`. Each entry is a self-contained React component named `<Name>.jsx` plus a matching `<Name>.css` (unless noted as no-CSS). The shared `manifest.json` is the source of truth for files, dependencies, and recommended use.

How to use any of them:

1. Install the listed dependencies.
2. Copy `<Name>.jsx` (and `<Name>.css` when present) into the target app, keeping them next to each other so the relative `./` CSS import resolves.
3. Render the component inside a positioned wrapper that has an explicit height. The component fills its parent.
4. Layer content above it (most canvases are transparent), and keep text contrast in check.

### Install by dependency group

Group components by their shared dependency to install once:

```bash
# ogl-based (the largest group)
npm install ogl
# components: LiquidEther uses three; Prism, DarkVeil, LightRays, EvilEye,
# LineWaves, Radar, SoftAurora, Aurora, Plasma, PlasmaWave, Particles,
# GradientBlinds, Grainient, PrismaticBurst, Galaxy, FaultyTerminal,
# RippleGrid, Threads, Iridescence, Orb, LiquidChrome, Balatro

# three.js core
npm install three
# components: LiquidEther, LightPillar, FloatingLines, ColorBends,
# PixelSnow, GridDistortion, Ballpit

# three + postprocessing
npm install three postprocessing
# components: PixelBlast, Hyperspeed

# react-three-fiber stack
npm install three @react-three/fiber @react-three/drei
# components: Silk (fiber only), Beams (fiber + drei)

# react-three dithering stack
npm install three postprocessing @react-three/fiber @react-three/postprocessing
# components: Dither

# face tracking
npm install three face-api.js postprocessing
# components: GridScan

# gsap (DotGrid also needs the InertiaPlugin)
npm install gsap
# components: DotGrid, GridMotion

# no external dependency (vanilla canvas / WebGL)
# components: Lightning, DotField, Waves, LetterGlitch, ShapeGrid
```

### Catalog

Pick by the mood you want. All are opt-in expressive surfaces.

- **LiquidEther** (`three`) — Pointer-reactive fluid simulation with idle auto-demo. Transparent.
- **Prism** (`ogl`) — Ray-marched glowing prism with rotate / hover / 3D-rotate modes. Transparent.
- **DarkVeil** (`ogl`) — Dark CPPN gradient veil with hue shift, noise, scanlines, and warp.
- **LightPillar** (`three`) — Ray-marched vertical light pillar with gradient color and grain; auto-downgrades quality on mobile.
- **Silk** (`three`, `@react-three/fiber`) — Animated silk-like shader texture. No CSS file (uses fiber `<Canvas>`).
- **FloatingLines** (`three`) — Layered flowing wave lines with parallax and pointer bend.
- **LightRays** (`ogl`) — Volumetric light rays with configurable origin and mouse-following. Transparent, pointer-events off.
- **PixelBlast** (`three`, `postprocessing`) — Pixelated dithered pattern with shape variants, click ripples, and liquid distortion. Transparent.
- **ColorBends** (`three`) — Warping color band field with custom palette, parallax, and pointer influence. Transparent.
- **EvilEye** (`ogl`) — Fiery animated eye with iris noise, glow, and pupil cursor tracking. Transparent.
- **LineWaves** (`ogl`) — Abstract warped line waves with color cycling and pointer distortion. Transparent.
- **Radar** (`ogl`) — Radar scan with rings, spokes, and rotating sweep beam. Transparent.
- **SoftAurora** (`ogl`) — Soft Perlin-noise aurora band with cosine-gradient layers. Transparent.
- **Aurora** (`ogl`) — Classic aurora gradient ribbon with a three-stop color ramp. Transparent.
- **Plasma** (`ogl`) — Ray-marched plasma with tint, direction, scale, and pointer interaction. Transparent.
- **PlasmaWave** (`ogl`) — Two-color plasma wave bands with adjustable bend and focal length. Transparent.
- **Particles** (`ogl`) — 3D particle field with count, spread, colors, and hover movement. Transparent.
- **GradientBlinds** (`ogl`) — Animated gradient with blind stripes, noise, and a mouse-tracked spotlight; supports `mix-blend-mode`.
- **Grainient** (`ogl`) — Grainy three-color gradient with warp and film grain; pauses offscreen. Transparent.
- **GridScan** (`three`, `face-api.js`, `postprocessing`) — Perspective grid with scan beam, bloom, chromatic aberration, and optional webcam/gyro tracking. Transparent.
- **Beams** (`three`, `@react-three/fiber`, `@react-three/drei`) — Animated 3D light beams over a noise-displaced plane.
- **PixelSnow** (`three`) — Volumetric pixelated snowfall with wind direction and retro pixel resolution. Transparent.
- **Lightning** (none) — Raw-WebGL fractal lightning bolt with hue, speed, and size. Transparent.
- **PrismaticBurst** (`ogl`) — Prismatic ray burst with rotate / rotate3d / hover and gradient or spectral colors.
- **Galaxy** (`ogl`) — Layered starfield with hue shift, twinkle, auto rotation, and mouse repulsion. Transparent.
- **Dither** (`three`, `postprocessing`, `@react-three/fiber`, `@react-three/postprocessing`) — Retro Bayer-dithered wave field with mouse interaction.
- **FaultyTerminal** (`ogl`) — Glitching CRT terminal of glyphs with scanlines, flicker, and chromatic aberration.
- **RippleGrid** (`ogl`) — Perspective grid with ripple distortion, optional rainbow, glow, and vignette. Transparent.
- **DotField** (none) — Canvas 2D + SVG dot grid with cursor bulge, glow, and optional sparkle.
- **DotGrid** (`gsap` + InertiaPlugin) — Dot grid with inertia, proximity color shift, and click shockwaves.
- **Threads** (`ogl`) — Flowing Perlin-noise thread lines with optional pointer interaction. Transparent.
- **Hyperspeed** (`three`, `postprocessing`) — Streaking car-light highway with distortion presets and bloom; memoize `effectOptions`.
- **Iridescence** (`ogl`) — Iridescent flowing color shader with optional mouse reactivity.
- **Waves** (none) — Canvas 2D Perlin-noise line waves with cursor spring interaction. Transparent.
- **GridDistortion** (`three`) — Image-based grid distortion that warps a source image around the cursor.
- **Ballpit** (`three`) — Physics-based 3D ball pit with gravity, friction, and cursor-following sphere. No CSS file (inline-styled canvas). Transparent.
- **Orb** (`ogl`) — Glowing animated orb with hue, hover distortion, and rotate-on-hover. Transparent.
- **LetterGlitch** (none) — Canvas grid of glitching characters with colors, speed, and vignettes. No CSS file (inline styles).
- **GridMotion** (`gsap`) — Rotated grid of content tiles scrolling on mouse position.
- **ShapeGrid** (none) — Scrolling grid of shapes (square/hexagon/circle/triangle) with a hover fill trail. Transparent.
- **LiquidChrome** (`ogl`) — Liquid chrome distortion shader with base color, amplitude, and mouse/touch ripples.
- **Balatro** (`ogl`) — Spinning pixel-filtered paint swirl with three-color blend and optional rotation.

Three components ship without a CSS file because their source styles the canvas inline: `Silk`, `Ballpit`, and `LetterGlitch`. Import only the `.jsx` for those.

## Product Defaults

- Keep `resolution` at `0.5` or lower for cost; raise it only when the surface is small.
- Keep the palette aligned with the project brand. The default `#5227FF`, `#FF9FFC`, `#B497CF` is a starting point, not a mandate.
- Maintain text contrast over the background. Add a flat or slightly translucent layer behind copy when needed.
- Pause rendering when the surface is not visible. Many components do this automatically (e.g. `LiquidEther`, `Grainient`, `PrismaticBurst`); `Prism` accepts `suspendWhenOffscreen`. All clean up on unmount, so do not duplicate that logic.
- Heavier components (`Hyperspeed`, `Dither`, `GridScan`, `Beams`, `Ballpit`) cost more GPU; reserve them for short-lived hero/splash moments and avoid stacking them. `GridScan` can request webcam access when `enableWebcam` is set — only opt in with user consent.
- Respect reduced motion: when `prefers-reduced-motion` is set, render a static fallback (a flat color or gradient) instead of mounting the simulation.
- Use one expressive background per view at most.
