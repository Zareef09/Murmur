# Murmur Design System

A design system for **Murmur**, a voice-first iOS capture app: you tap once, say a natural task out loud — "remind me to call mom tomorrow at 5" — and it quietly becomes a reminder or a calendar event. When it isn't sure, it asks a short spoken follow-up.

The product does one thing, in 5–15 second bursts, usually one-handed and often mid-motion — walking, driving, cooking, between meetings. The emotional job is to relieve the small anxiety of *I need to remember this before I forget*. Everything here serves that: **a held breath being let out.**

## Sources

This system was built from a **written design brief only** (pasted into the project on 15 Aug 2026 under the working title "Capture" — see §1–15 of that brief). There was:

- no codebase or repository,
- no Figma file or link,
- no existing brand, logo, or font licence,
- no slide deck or prior collateral.

So everything below is authored, not recreated. The brief explicitly asked for the identity (name, wordmark, app icon) and for the signature interaction to be proposed rather than applied. Two consequences worth knowing:

1. **Fonts are Google Fonts stand-ins, loaded from the CDN.** Hanken Grotesk (core) and IBM Plex Mono (meta). No licensed binaries were supplied, so `tokens/fonts.css` uses an `@import`, not `@font-face`. Drop real `.woff2` files into `assets/fonts/` and swap in `@font-face` rules when the brand licenses a cut.
2. **Icons are Lucide, copied into `assets/icons/`.** The brief asks for SF Symbols in the shipping app; SF Symbols cannot be redistributed here, and Lucide's 2px round-cap line style is the closest freely-usable match. See ICONOGRAPHY.

## Naming — three proposals

| Name | Rationale |
| --- | --- |
| **murmur** *(lead — used throughout this system)* | A murmur is the quietest form of speech: something said almost to yourself. It names the input *and* the volume of the whole product. Short, lowercase, calm, and searchable — the App Store has no calendar/reminder product on it. |
| **Offhand** | Names the moment rather than the mechanism: the thought you have offhand, mid-stride, and lose. Warmer and wryer than murmur; slightly harder to say out loud as an app name. |
| **Ember** | The warm-light-source metaphor made literal — a thing kept glowing until you need it. Beautiful, but crowded: several apps already use it. |

The wordmark is **`murmur`** — always lowercase, core face at weight 300, tracked +0.13em, with a small ember dot after the final *r*: the thought, let out and safely kept. The app icon is the capture well reduced to a warm ground, two hairline rings and an ember core — deliberately **not** a microphone. See `components/brand/` and the Home Screen in `ui_kits/murmur-ios/gallery.html`.

## The signature interaction — Light Well

Three interpretations were explored (live, side by side, in `guidelines/signature-interaction.html`):

- **A · Light Well — chosen.** A warm bloom behind three hairline rings. Each ring answers the voice ~90ms after the one inside it, so the response reads as breath, not as a level meter.
- **B · Horizon.** A single line that bows with volume, with a slower echo behind it. Lovely and quiet, but a line carries "thinking" and "done" poorly.
- **C · Grain Field.** Twenty columns lifting in a travelling wave. The closer it gets to a real waveform, the more it reads as recording hardware — the opposite of the intended calm.

The Light Well is one element in four states — **idle · listening · thinking · done** — and it morphs between them; it is never replaced by a different screen. It owns the accent colour: nothing else on the capture screen may use ember.

---

# CONTENT FUNDAMENTALS

**Voice: a competent person who is already listening.** Short sentences, plain words, present tense. It never performs enthusiasm and never apologises.

- **Person.** The app says *you*, and refers to itself by name in the third person when it must ("Murmur asks out loud when it needs one more detail"). It avoids *I* except in the one place it is literally speaking: the listening placeholder, **"I'm listening…"**.
- **Casing.** Sentence case everywhere — buttons, titles, rows. Uppercase is used only for 12px field captions with +0.08em tracking (`WHEN`, `GOES TO`). Title Case never appears. The wordmark is always lowercase.
- **Punctuation.** Full stops in body copy; none on buttons or single-line row labels. Em dashes are avoided; the middle dot separates facts in one line: `Saved to Reminders · tomorrow 5:00 PM`. The ellipsis is reserved for in-flight speech.
- **Length.** Titles ≤ 6 words. Body ≤ 2 lines at default Dynamic Type. Captions ≤ 1 line.
- **Emoji: never.** Not in UI, not in copy, not in the App Store description. Unicode ornament is limited to `·`.
- **Questions.** Clarification asks one thing, phrased as a person would: "Which day did you mean — Friday or Saturday?" Not "Ambiguous date detected."
- **Errors don't exist as a category.** Missing information is stated as fact in tertiary text — `No date`, `Not allowed yet` — never in red, never with "failed", "error", "invalid", or an exclamation mark. The strongest word in the system is *needed*.
- **Permissions are framed by why, not by what.** "Your microphone, so Murmur can hear you." Never the system's own language.
- **Success is a statement, not a celebration.** "Saved to Reminders · tomorrow 5:00 PM" — then Undo. Never "Great!", "Done!", "Nice work".

Sample copy, verbatim from the kit:

> Say what you need to remember.
> Murmur files it as a reminder or an event. You can always check before it saves.
> Does this look right? · Tap anything to change it.
> Somewhere quiet? Tap an answer instead.
> Nothing captured yet. Tap the well on the home screen and say the thing you keep almost forgetting.

---

# VISUAL FOUNDATIONS

**Warm Minimal.** Soft natural light, linen and cream, generous quiet space, one gentle accent. Apple-grade restraint, but warmer and softer.

### Colour
Warmth comes from the **neutrals**, never from saturation. The Sand ramp (`--sand-0` → `--sand-1000`) has no blue in it at any step. Light mode is linen (`#FAF6EF`), never stark white; dark mode is warm near-black (`#100E0B`), never pure black or cold charcoal — and it is designed, not inverted (foreground and tint values are re-tuned per mode).

One accent: **Ember**, a warm ochre-terracotta. It is the "single warm light source in the room" and it appears only on (a) the capture element while active, and (b) the one primary action per screen. Two destination hues sit either side of it — **moss** for Reminders, **plum** for Calendar Events — chosen to be distinguishable at a glance yet harmonious with terracotta. Semantics stay in the same world: **leaf** for success, **clay** for attention (warm, never alarm-red).

Measured contrast: `--accent` on `--bg-base` 4.9:1; `--text-accent` on `--bg-base` 6.2:1; `--accent-on` on `--accent` 6.1:1; dark-mode accent on `--bg-base` 9.8:1. All AA or better. Never rely on hue alone — Reminder and Event always carry icon **and** word.

### Type
One family does almost everything: **Hanken Grotesk**, a humanist grotesque with soft terminals and excellent light weights. Display and title run 200/300; body is 17px/400 to match iOS; anything below 17px runs 400–500 so it survives a glance. 12px is the hard floor. **IBM Plex Mono** appears only at 11–13px for timestamps and durations — a small typographic signal that a value is machine-read. Weight 600 is the ceiling; nothing is bold.

### Layout
24px screen gutters, 56px between sections, 4px base scale used mostly at its top end. Air is the brand: the capture screen is one element and two lines of text. Content respects safe areas and the Dynamic Island; the capture well sits on the optical centre, slightly above geometric middle, so it stays in thumb reach. Touch targets: 44px floor, 56px for rows, 96px+ for the hero. Layouts are single-column and flow-based so Dynamic Type can grow without breaking anything — no fixed heights on text containers.

### Surfaces, borders, shadows
Depth comes from **layered warm values first** (`--bg-sunk` / `--bg-base` / `--bg-raised`) and **hairlines second** (`--line-hairline` at 7% warm black). Shadow is third and barely there: warm-tinted, wide, 4–10% opacity. Never stack two shadows. The only "glow" in the system is `--shadow-listening` on the capture core while it hears you.

Cards and rows: raised surface, 22px radius, 1px hairline, `--shadow-row` or `--shadow-card`. Sheets: 28px top corners, `--shadow-sheet`. Nothing sharper than 8px exists in the product. No coloured left borders, no outlined "callout" cards.

### Gradients, imagery, texture
Effectively no gradients. Two exceptions, both radial and both nearly invisible: `.mm-light-wash` (an off-centre wash of ember at 12% behind the capture screen) and the bloom inside the capture element. No photography in v1 — no stock imagery, no illustration, no hand-drawn marks, no repeating pattern, no grain overlay. If photography is ever introduced it should be warm, soft-focus, low-contrast interior light; never cool, never clinical.

### Transparency and blur
Used sparingly and only where iOS would: `--bg-overlay` behind a presented sheet, `--bg-scrim` + `--blur-scrim` for a bar over scrolling content. Never behind text without a solid surface underneath.

### Motion
Quiet motion, always decelerating, as though everything had a little weight and met air resistance. House curve `--ease-exhale` (`cubic-bezier(.22,.61,.24,1)`); `--ease-inhale` for the 3.8s idle breath; `--ease-settle` for the success landing. Durations: 120ms press, 220ms controls, 380ms cross-fades and sheets, 620ms state morphs. **No springs, no overshoot, no bounce, no confetti.** State changes are one continuous morph of a single element, not a cut between screens. `prefers-reduced-motion` collapses every duration to 1ms. Storyboards for the three key moments live in `guidelines/motion-storyboard.html`.

### Interaction states
- **Press** (the primary state on iOS): a 1.8% scale settle on buttons, 6% on icon buttons, plus a one-step-darker fill (`--accent-press`). No shadow change, no colour flash.
- **Hover** (only meaningful in these web recreations): background moves one warm step — `--bg-sunk` for quiet controls, `--accent-quiet` for ghost. Opacity is never used to signal hover.
- **Selected**: tinted fill + 1px hairline in the same hue + medium weight — three signals, so it never depends on colour.
- **Disabled**: 38% opacity, no interaction, no explanatory text.
- **Focus**: 2px accent ring (`--stroke-focus`), for keyboard and Switch Control.

---

# ICONOGRAPHY

- **Set:** [Lucide](https://lucide.dev) (ISC), copied into `assets/icons/` as individual SVGs. 24×24 grid, 2px stroke, round caps and joins — the closest freely-redistributable match to SF Symbols' line weight. **This is a flagged substitution:** the shipping SwiftUI app should use the equivalent SF Symbol (`bell`, `calendar`, `mic`, `clock`, `pencil`, `trash`, `checkmark`, `exclamationmark.circle`, `chevron.right`, …); these files exist so the design system can render without shipping Apple's set.
- **How they're used:** always through the `Icon` component, which paints the SVG as a CSS mask so it takes `currentColor` and can never be off-palette. Set `window.MURMUR_ICON_BASE` once per page to the right relative path.
- **Sizes:** 13–14px inside chips and captions, 16px trailing chevrons, 19–20px row leading and buttons, 26px in empty states. Icons sit at `--text-tertiary` when decorative, at the destination hue when semantic.
- **No emoji, ever.** No unicode glyphs as icons; the only unicode ornament is the middle dot `·`. No icon fonts. No custom-drawn illustration — the one piece of brand geometry (the well, the icon, the wordmark dot) is built from CSS circles, not artwork.
- **Semantic pairs that must stay fixed:** Reminder → `bell` + moss; Event → `calendar` + plum; granted → `check` + leaf; needs attention → `circle-alert` + clay; listening → the capture well itself, never a mic glyph.
- **Logo:** no logo was supplied. The app logo is the letter **M** (`AppIconM`) — a single monoline stroke, flat ground, no other geometry — paired with a wordmark (`Wordmark`) now also set as `M`. The earlier Light Well icon geometry (`AppIcon`) remains for the capture screen states. There is no `assets/logo.svg`.

---

# Index

| Path | What it is |
| --- | --- |
| `styles.css` | The entry point consumers link. `@import` list only. |
| `tokens/` | `fonts.css`, `colors.css`, `typography.css`, `spacing.css`, `radius.css`, `elevation.css`, `motion.css`, `base.css` (resets, `.mm-light-wash`, shared keyframes). |
| `guidelines/` | Foundation specimen cards (colour, type, spacing, motion, elevation) plus `signature-interaction.html` and `motion-storyboard.html`. |
| `components/` | The reusable primitives, grouped by concern. |
| `ui_kits/murmur-ios/` | The full app: interactive `index.html`, every-state `gallery.html`, `README.md`. |
| `assets/icons/` | Lucide SVGs used by the `Icon` component. |
| `SKILL.md` | Agent-Skills wrapper so this folder can be used from Claude Code. |

## Components

**`components/core/`** — `Button` (primary / secondary / ghost, sm–lg), `IconButton` (quiet / surface / accent), `Icon`.
**`components/capture/`** — `CaptureBloom` (the signature light well, 4 states), `Transcript` (live caption), `SuccessBar` (success + Undo).
**`components/fields/`** — `EditableField` (tap-to-edit parsed value), `DestinationToggle` (Reminder ↔ Event), `ToggleRow` (settings preference).
**`components/data/`** — `DestinationBadge` (chip / glyph / quiet), `HistoryRow` (with swipe-to-delete), `PermissionRow` (granted / needed), `EmptyState`.
**`components/brand/`** — `Wordmark` (the letter M), `AppIconM` (the app logo), `AppIcon` (Light Well, capture screen).

Every component has a sibling `.d.ts` (props contract) and `.prompt.md` (what & when, usage, variants). Each directory has one `@dsCard` HTML showing its states densely.

The inventory is exactly the component sheet the brief asked for (§6). **Intentional additions:** `Icon` (a wrapper the glyph set needs to stay on-palette), `IconButton` (the brief's History/Settings entries need a target, and `Button` is the wrong shape for them), and `Group` inside the UI kit (the grouped-list container Settings and History both sit in — kit-local, not a system primitive).

## UI kits

`ui_kits/murmur-ios/` — every screen in every state from §5 of the brief, in light and dark: onboarding ×3, Home Screen with the app icon, Capture (first-run / idle / listening / processing / success+Undo), Confirmation (confident / correcting), Clarification (listening / answered), History (populated / empty), Settings. `gallery.html` shows all of them as live light+dark pairs.

## Known gaps

- Fonts are CDN stand-ins (see Sources). **Please supply licensed font files.**
- Icons are Lucide, not SF Symbols (see ICONOGRAPHY).
- No photography or illustration exists; if the brand wants any, it needs art direction and real assets.
- Contrast ratios above are computed from the token hex values; re-verify on device with a measuring tool before ship.
