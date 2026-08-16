# Murmur — Design brief (shipping)

> Working name in early docs: Capture. Display name: **Murmur**.  
> This file is the **visual and copy contract** for SwiftUI. Pixel-level tokens, components, and the click-through kit live in the frozen reference: [design-system/](design-system/) ([readme.md](design-system/readme.md), [REFERENCE.md](design-system/REFERENCE.md)).  
> Product behaviour: [CAPTURE_SPEC.md](CAPTURE_SPEC.md). Session protocol: [CAPTURE_MASTER_PLAN.md](CAPTURE_MASTER_PLAN.md). Security: [SECURITY.md](SECURITY.md) (Session 3).

Do not edit `docs/design-system/` to change the app. Port into `Capture/DesignSystem/` in Swift.

---

## 1. Job of the interface

The product does one thing in 5–15 second bursts, usually one-handed and mid-motion. The emotional job is to relieve *I need to remember this before I forget*. Everything visual serves that: **a held breath being let out.**

---

## 2. Identity

- **Wordmark:** `murmur` — always lowercase, Hanken Grotesk 300, tracking +0.13em, small ember dot after the final *r*.
- **App icon:** capture well reduced to a warm ground, two hairline rings, ember core. **Not a microphone.** See `design-system/components/brand/`.
- **Rejected names** (do not ship): Offhand, Ember.

---

## 3. Signature interaction — Light Well

Chosen in `design-system/guidelines/signature-interaction.html` (Horizon and Grain Field are not to be built).

One element, four states — **idle · listening · thinking · done** — morphing, never a cut to a different hero.

| State | Feel |
| --- | --- |
| idle | 3.8s inhale/exhale breath on the rings |
| listening | Warm bloom; three hairline rings answer amplitude ~90ms apart (breath, not a meter) |
| thinking | Quiet hold while parse/classify runs |
| done | Settle into success; then the Success Bar (Undo, 5s) |

Rules:

- Exactly one Light Well on the capture screen. It **owns Ember**; nothing else on that screen may use the accent.
- Diameter **240** on capture home, **120** in the confirmation header.
- Feed **smoothed** amplitude (≈120ms attack, ≈400ms release). Raw RMS reads as hardware.
- No text label inside the well. Caption sits underneath (“Tap to speak”, “I'm listening…”, etc.).
- `prefers-reduced-motion`: collapse durations to 1ms (still change state, do not bounce).

Swift component: `CaptureBloom`. Kit: `design-system/components/capture/CaptureBloom.jsx`.

---

## 4. Copy voice

**A competent person who is already listening.** Short sentences, plain words, present tense. No enthusiasm performance, no apology.

- Person: *you*; the app is “Murmur” in the third person. The only *I* is the listening placeholder: **I'm listening…**
- Sentence case everywhere. Title Case never. Uppercase only for 12pt field captions (`WHEN`, `GOES TO`) at +0.08em.
- No full stops on buttons or single-line row labels. Middle dot separates facts: `Saved to Reminders · tomorrow 5:00 PM`. Ellipsis only for in-flight speech.
- Titles ≤ 6 words. Body ≤ 2 lines at default Dynamic Type. Captions ≤ 1 line.
- **No emoji.** Ornament is `·` only.
- Clarification asks one human question: “Which day did you mean — Friday or Saturday?” Not “Ambiguous date detected.”
- There is no “error” category. Facts in tertiary text: `No date`, `Not allowed yet`. Never “failed”, “error”, “invalid”, or `!`. Strongest word: *needed*.
- Permissions by why: “Your microphone, so Murmur can hear you.”
- Success is a statement + Undo. Never “Great!”, “Done!”, “Nice work”.
- Sign in with Apple is a statement, not a celebration. One primary: “Continue with Apple”.

Kit samples (verbatim):

> Say what you need to remember.  
> Murmur files it as a reminder or an event. You can always check before it saves.  
> Does this look right? · Tap anything to change it.  
> Somewhere quiet? Tap an answer instead.  
> Nothing captured yet. Tap the well on the home screen and say the thing you keep almost forgetting.

History empty (3-day memory, not an archive) should stay in this voice — short memory, not a scolding.

---

## 5. Visual foundations (Swift mapping)

Full ramps: `design-system/tokens/colors.css` and related token files.

- **Warm Minimal.** Linen light `#FAF6EF`, warm near-black dark `#100E0B`. Sand has no blue.
- **Ember** — listening well + the one primary action per screen.
- **Moss + bell** = Reminder. **Plum + calendar** = Event. Never colour alone.
- **Leaf** = granted/success. **Clay** = attention (not alarm-red).
- Type: Hanken Grotesk (bundle OFL in the app; do not load Google Fonts at runtime). IBM Plex Mono only for 11–13pt meta. Weight ceiling 600. Floor 12pt. Body 17pt to match iOS. Transcript 26pt / 300.
- Layout: 24pt gutters, 56pt between sections. Hits: 44 / 56 / 96+ hero. Optical centre for the well (slightly above geometric middle).
- Radius: nothing sharper than 8pt; rows 22; sheets 28 top; pills 999.
- Motion: `--ease-exhale` `cubic-bezier(.22,.61,.24,1)`; press 120ms; controls 220ms; sheets/cross-fades 380ms; state morphs 620ms; idle breath 3800ms; **Undo 5000ms**. No springs, overshoot, bounce, or confetti.
- Icons in the shipping app: **SF Symbols** (`bell`, `calendar`, `clock`, `pencil`, `trash`, `checkmark`, `exclamationmark.circle`, `chevron.right`, …). Lucide SVGs stay in the design-system folder only. Listening is the well, never a mic glyph on capture home.

---

## 6. Screen inventory (kit parity)

Interactive kit: `design-system/ui_kits/murmur-ios/index.html`  
Every state, light and dark: `design-system/ui_kits/murmur-ios/gallery.html`

Onboarding ×3, Sign in with Apple (app addition — match kit voice), Capture (first-run / idle / listening / processing / success+Undo), Confirmation (confident / correcting), Clarification (listening / answered), History (populated / empty), Settings (toggles, permissions, sign out).

---

## 7. Component inventory to port

`Button`, `IconButton`, `Icon`, `CaptureBloom`, `Transcript`, `SuccessBar`, `EditableField`, `DestinationToggle`, `ToggleRow`, `DestinationBadge`, `HistoryRow`, `PermissionRow`, `EmptyState`, `Wordmark`, `AppIcon`.

Each has `.jsx`, `.d.ts`, `.prompt.md` under `design-system/components/`.
