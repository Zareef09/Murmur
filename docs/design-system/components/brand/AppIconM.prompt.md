# AppIconM

The app logo. A single letter M, drawn as one continuous monoline stroke with
rounded joints — no other geometry, no rings, no microphone, no accent dot.

The M is the whole mark. Nothing else in the frame competes with it — flat
ground, one hairline, one soft shadow, done. The dark ground is the only
icon used app-wide (App Store icon, home screen, favicon).

## Usage

```jsx
<AppIconM size={120} />
```

Use for the App Store icon, home-screen icon, favicon, and anywhere the brand
needs a mark without the wordmark attached. Pair with `Wordmark` (now set in
`M` only) for a full lockup — see `brand.card.html`.

## Variants

- `theme="dark"` (default) — flat near-black ground, warm cream ink M. The only variant in app use.
- `theme="light"` — flat sand ground, warm dark ink M. Kept in code for contexts needing a light ground; not used as the app icon.
