# Murmur — Master build plan (Cursor execution)

> Display name: **Murmur**. Visual: [CAPTURE_DESIGN_BRIEF.md](CAPTURE_DESIGN_BRIEF.md) + [design-system/](design-system/). Behaviour: [CAPTURE_SPEC.md](CAPTURE_SPEC.md). Security: [SECURITY.md](SECURITY.md) (Session 3).

This is the execution doc. Deep technical detail lives in the spec; visual detail lives in the brief and the frozen design system. Keep all three in the repo.

---

## PART 1 — Operating protocol (follow exactly)

You are building this app **one session at a time, on command.** Do not build ahead.

1. **Do nothing until the user says "Start Session N" (or "Do Session N").** Until then, you may answer questions about the plan, but write no product code.
2. When told to start a session, execute **only that session** — every task in it, fully — then **stop.**
3. **Never combine, skip, or reorder sessions** unless the user explicitly tells you to.
4. At the **end of every session**, you must:
   - Summarize in plain English what you changed (files added/edited).
   - Confirm each item in that session's **Definition of Done** (or flag what isn't and why).
   - Note anything the user must do manually.
   - Tick the session's checkbox in **PART 4 — Session log** and add a one-line note.
   - Then **STOP and wait.**
5. **Every session must leave the project in a building, runnable state.** Docs-only sessions S01–S11 may precede the first Xcode build (S12). If a later session can't compile on its own, it's scoped wrong — stop and tell the user.
6. If you hit a blocker (missing decision, ambiguous requirement, Open Decision in the spec), **stop and ask** — do not guess.
7. Speech, on-device recognition, EventKit, Sign in with Apple, and widgets behave unreliably in the Simulator. When a DoD needs hardware, **say so** and mark **needs device verification by user.**
8. Keep to the stack in PART 2. The **only** third-party package allowed is official **supabase-swift**. No other SDKs, no CloudKit, no Foundation Models, no CDN fonts at runtime.
9. Schema: local first; never put `service_role` in the iOS app; never use `user_metadata` in RLS. Prefer `supabase migration new` then pull when committing SQL (Supabase skill).
10. Match existing code style and folder structure as the codebase grows. Prefer small, single-responsibility files.

**Session hand-off format (use this every time):**

```
✅ Session N complete — <title>
Changed: <files>
Definition of Done: <each item ✓ / ✗ with note>
Your turn (manual): <anything the user must do>
Stopping here. Say "Start Session N+1" when ready.
```

---

## PART 2 — Global rules and stack

- Swift 6, SwiftUI, MVVM. Logic in Services/ViewModels, never in Views.
- Min deployment: iOS 17.0. iOS 18+ Control Center is availability-guarded.
- Speech on-device (`requiresOnDeviceRecognition = true`). EventKit on-device. History on-device, **3-day TTL**.
- Supabase: Auth (Sign in with Apple) + `profiles` / `user_settings` with **RLS**. No history, audio, transcripts, or EventKit IDs in the cloud.
- Audio golden rule: recording **or** speaking, never both. `AudioSessionManager` gates the transition.
- Undo window: **5 seconds** (design token). Confirm-before-save default: **ON**.
- Ember only on the Light Well (active) and the one primary action per screen.

---

## PART 3 — Condensed architecture

See [CAPTURE_SPEC.md](CAPTURE_SPEC.md). Summary:

**Core = one state machine** owned by `CaptureViewModel`:  
`signedOut → idle → listening → processing → (clarifying ↔ ) confirming → saving → success` (+ `failed`).

Reminder vs Calendar (deterministic — spec §6.3): explicit time → Calendar event; date-only or none → Reminder (date-no-time-no-keyword is an **Open Decision**); vague/garbled → clarify. Confidence &lt; 0.5 → spoken clarification, one loop.

---

## PART 4 — Session log (tick here)

`[ ]` = not started, `[x]` = done.

**Phase D — Docs**

- [x] S01 — Copy design system — Frozen tree at `docs/design-system/` (125 files), `REFERENCE.md`, commit f707112.
- [x] S02 — Master docs — This file + spec + design brief, cross-linked.
- [x] S03 — Security threat model — `docs/SECURITY.md` (inventory, RLS SQL, SIWA nonce, keys, logging, privacy label).

**Phase B — Supabase (local first)**

- [x] S04 — Git ignore — Root `.gitignore` for Xcode/Swift, `.env`, `supabase/.env`, `*.local.xcconfig`, keys, `.DS_Store`.
- [x] S05 — `supabase init` — `supabase/config.toml` (Realtime/Storage off); `docs/LOCAL_SUPABASE.md`. Docker not running here; user must `supabase start`.
- [x] S06 — `profiles` + auth trigger — migration `20260815231221_profiles_and_auth_trigger.sql`. Needs `supabase start` / `db reset` to prove a new auth user gets a profile.
- [x] S07 — `user_settings` — migration `20260815231443_user_settings_and_trigger.sql`; trigger inserts settings (`always_confirm` true). Needs Docker to prove.
- [x] S08 — RLS policies — migration `20260815231518_rls_profiles_and_user_settings.sql` (FORCE RLS, revoke anon, per-command `(select auth.uid())`).
- [x] S09 — RLS proof — live pass 15 Aug 2026 (all 7 cases). Use `docker exec … psql`, not `db query`.
- [x] S10 — Database advisors — live pass 15 Aug 2026 (`No issues found`).
- [x] S11 — Sign in with Apple dashboard checklist — `docs/APPLE_AUTH.md` (native-required vs optional Services ID / .p8 / callback).
- [ ] S06 — `profiles` + auth trigger
- [ ] S07 — `user_settings`
- [ ] S08 — RLS policies
- [ ] S09 — RLS proof
- [ ] S10 — Database advisors
- [ ] S11 — Sign in with Apple dashboard checklist

**Phase 0 — Xcode scaffolding**

- [x] S12 — Xcode project — `Murmur.xcodeproj`, Swift 6, iOS 17, display name Murmur, bundle `app.murmur.capture`. Simulator Debug build succeeded.
- [x] S13 — Hardened project settings — Sign in with Apple entitlement only; no Push/iCloud/associated domains.
- [x] S14 — Folder skeletons — Models/Services/ViewModels/Views/Intents/DesignSystem stubs; still launches blank.
- [x] S15 — CaptureViewModel shell — `state` defaults to `signedOut`; DEBUG preview flips all cases.
- [x] S16 — SPM: supabase-swift — official package 2.55.1 (`Supabase` product); Debug simulator build succeeded.
- [ ] S14 — Folder structure & compiling skeletons
- [ ] S15 — CaptureViewModel state machine shell
- [ ] S16 — SPM: supabase-swift
- [x] S17 — Supabase client — fail-closed `SupabaseClientProvider`; Debug includes gitignored `Config/Supabase.local.xcconfig`; launch reads `currentSession`.
- [x] S18 — AuthService: Sign in with Apple — native nonce + `signInWithIdToken`; local `[auth.external.apple]` on. Needs device.
- [x] S19 — Session restore + sign out — Keychain (`app.murmur.capture.auth`, no App Group); launch restore; Settings Sign out. Needs device kill/relaunch.
- [x] S20 — Sign-in view — DS-aligned linen/ember screen; one primary “Continue with Apple”; light + dark previews.
- [x] S21 — Gate the app — signed out → `SignInView`; signed in → `CaptureView`; `canCapture` false without a session.
- [x] S22 — SettingsRepository local cache — UserDefaults last-known `always_confirm` (default true, per user); capture reads cache only.
- [x] S23 — Settings sync — fetch/upsert `user_settings` (session uid only, RLS); 500ms debounce; cache first. Needs device + network for reinstall proof.
- [x] S24 — Auth error copy — `AuthCopy`: cancel = “Not now”; network = “A connection is needed…”. No error/failed in UI.

**Phase DS — Tokens and components**

- [x] S25 — Color tokens — `MurmurColor` ramps + semantic light/dark; catalog previews. Ember = well + one primary.
- [x] S26 — Spacing, radius, hit targets — `MurmurSpace` / `MurmurRadius`; layout catalog light/dark.
- [x] S27 — Typography — bundled OFL Hanken Grotesk + IBM Plex Mono; `MurmurType`; catalog light/dark.
- [x] S28 — Motion + elevation — `MurmurMotion` (undo 5s, Reduce Motion 1ms); `MurmurElevation`; catalog.
- [x] S29 — Theme + light wash — `murmurCanvas(wash:)`; capture has off-centre ember wash; sign-in is flat linen.
- [x] S30 — MurmurIcon — SF Symbols via `MurmurIconName`; Lucide not bundled. Catalog light/dark.
- [x] S31 — MurmurButton — primary / secondary / ghost; ember primary; press settle; Sign-in uses it.
- [x] S32 — MurmurIconButton — quiet / surface / accent; 44pt min; capture Settings uses quiet.
- [x] S33 — DestinationBadge — chip / glyph / quiet; Reminder moss + Event plum; icon and word together.
- [x] S34 — EmptyState, PermissionRow, ToggleRow — catalog; Settings confirm uses ToggleRow.
- [ ] S35 — DestinationToggle + EditableField
- [ ] S36 — TranscriptView + SuccessBar
- [ ] S37 — Wordmark + AppIconView
- [ ] S38 — CaptureBloom idle / thinking / done
- [ ] S39 — CaptureBloom listening + level

**Phase 0b — Persistence, permissions, onboarding**

- [ ] S40 — SwiftData `Capture` model
- [ ] S41 — ModelContainer + file protection
- [ ] S42 — HistoryPurgeService (3 days)
- [ ] S43 — LoggingPolicy
- [ ] S44 — PermissionsService
- [ ] S45 — Info.plist permission strings
- [ ] S46 — PrivacyInfo.xcprivacy
- [ ] S47 — Onboarding slide 1
- [ ] S48 — Onboarding slide 2
- [ ] S49 — Onboarding slide 3
- [ ] S50 — Onboarding + Apple + first-launch gate

**Phase 1 — Transcribe**

- [ ] S51 — AudioSessionManager
- [ ] S52 — SpeechService (on-device request)
- [ ] S53 — SpeechService stream + silence stop
- [ ] S54 — Unsupported locale path
- [ ] S55 — CaptureView idle
- [ ] S56 — Live transcript wiring
- [ ] S57 — Audio-level → Bloom

**Phase 2 — Parse, classify, save**

- [ ] S58 — ParsedIntent & CaptureDestination
- [ ] S59 — ParsingService: date extraction
- [ ] S60 — ParsingService: taskText cleanup
- [ ] S61 — Parsing tests A
- [ ] S62 — Parsing tests B
- [ ] S63 — ClassificationService
- [ ] S64 — Classification tests
- [ ] S65 — EventKitService: Reminder
- [ ] S66 — EventKitService: Event
- [ ] S67 — EventKit delete-by-id only
- [ ] S68 — Wire pipeline auto-save (temporary)

**Phase 3 — Confirmation**

- [ ] S69 — ConfirmationView (read-only)
- [ ] S70 — Inline edit: title + destination
- [ ] S71 — Inline edit: date/time
- [ ] S72 — Confirm/cancel + always-confirm toggle

**Phase 4 — Voice clarification**

- [ ] S73 — SpeechSynthService
- [ ] S74 — clarifying state + question templates
- [ ] S75 — record↔speak handoff + one-loop cap
- [ ] S76 — ClarificationView + tap fallback
- [ ] S77 — Merge answer → re-classify once

**Phase 5 — History**

- [ ] S78 — HistoryView list + row
- [ ] S79 — Deep-link to Reminders/Calendar
- [ ] S80 — Swipe delete (app-only vs also-external)
- [ ] S81 — Success + Undo

**Phase 6 — Quick-launch**

- [ ] S82 — QuickCaptureIntent
- [ ] S83 — Siri phrases (AppShortcutsProvider)
- [ ] S84 — Widget extension target
- [ ] S85 — Lock-screen accessory widget
- [ ] S86 — Control Center control (iOS 18+)
- [ ] S87 — Back Tap shortcut + onboarding setup

**Phase 7 — Polish and ship**

- [ ] S88 — Capture screen parity
- [ ] S89 — Remaining screens parity
- [ ] S90 — Motion polish
- [ ] S91 — Empty states + edge copy
- [ ] S92 — App icon assets
- [ ] S93 — Settings final polish
- [ ] S94 — Onboarding final polish
- [ ] S95 — Accessibility pass
- [ ] S96 — App Store prep
- [ ] S97 — Link migrations to hosted Supabase
- [ ] S98 — TestFlight build & submission

---

## PART 5 — The sessions (detailed)

Each session: **Goal**, **Do**, **Definition of Done**. Do not exceed the session's scope.

### Phase D

**S01 — Copy the design system**  
Goal: frozen visual source in-repo.  
Do: copy the Murmur design system → `docs/design-system/`; reference-only note.  
DoD: full tree in git.

**S02 — Master docs**  
Goal: the three execution files exist and agree.  
Do: write this file, `CAPTURE_SPEC.md`, `CAPTURE_DESIGN_BRIEF.md` (backend split, 3-day TTL, SIWA, Light Well).  
DoD: all three exist and cross-link.

**S03 — Security threat model**  
Goal: implementers do not invent policy.  
Do: `docs/SECURITY.md` — data inventory, RLS policy text, SIWA nonce, key handling, logging ban, Privacy Nutrition.  
DoD: S06–S09 and S17–S23 can follow the doc without guessing.

### Phase B

**S04 — Git ignore**  
Do: Xcode/Swift + `supabase/.env` + secrets + `.DS_Store`.  
DoD: ready for later commits.

**S05 — supabase init**  
Do: local stack only.  
DoD: `supabase start` documented (Docker).

**S06 — profiles + auth trigger**  
Do: migration; private-schema security-definer trigger on `auth.users`.  
DoD: new auth user gets a profile.

**S07 — user_settings**  
Do: table, `always_confirm` default true; trigger creates the row.  
DoD: new user has one settings row.

**S08 — RLS policies**  
Do: ENABLE + FORCE RLS; revoke anon; per-command policies with `(select auth.uid())`.  
DoD: SQL in repo.

**S09 — RLS proof**  
Do: user A cannot read/update B; anon sees nothing.  
DoD: documented pass.

**S10 — Database advisors**  
Do: run advisors; fix critical issues.  
DoD: no critical security advisor left.

**S11 — Sign in with Apple checklist**  
Do: `docs/APPLE_AUTH.md` (Services ID, key, return URL, dashboard).  
DoD: user can configure without guessing.

### Phase 0

**S12 — Xcode project**  
Do: iOS App, SwiftUI, Swift 6, iOS 17.0, display name Murmur, bundle id `app.murmur.capture`.  
DoD: builds, launches blank.

**S13 — Hardened settings**  
Do: Sign in with Apple capability; no Push/iCloud; no unused extras.  
DoD: entitlements match need.

**S14 — Folder skeletons**  
Do: protocols + stubs including `AuthServicing`, `SettingsSyncing`; `CaptureState`, `CaptureDestination`.  
DoD: launches; no logic.

**S15 — CaptureViewModel shell**  
Do: published `state` including `signedOut`.  
DoD: DEBUG preview can flip states.

**S16 — SPM: supabase-swift**  
Do: official package only.  
DoD: resolves and builds.

**S17 — Supabase client**  
Do: xcconfig URL + publishable/anon key; fail closed.  
DoD: session read does not crash.  
Done 15 Aug 2026: `SupabaseClientProvider`; Debug `Config/Supabase.debug.xcconfig` + gitignored local overlay; Release empty until S97.

**S18 — AuthService: Sign in with Apple**  
Do: native SIWA + nonce; `signInWithIdToken`. No `user_metadata` for authz.  
DoD: device: Apple sheet → session.  
Done 15 Aug 2026: `AuthService.signInWithApple`; hashed nonce to Apple, raw nonce to Supabase. Device verification still required.

**S19 — Session restore + sign out**  
Do: Keychain; Settings sign out.  
DoD: kill/relaunch stays signed in.  
Done 15 Aug 2026: `restoreSession` + Settings Sign out; Keychain service `app.murmur.capture.auth`. Device kill/relaunch still required.

**S20 — Sign-in view**  
Do: DS-aligned; one primary “Continue with Apple”.  
DoD: light + dark.  
Done 15 Aug 2026: `SignInView` (kit copy, ember primary, wordmark). Fonts still system until S27.

**S21 — Gate the app**  
Do: signed out → sign-in; signed in → capture.  
DoD: cannot capture without a session.  
Done 15 Aug 2026: `ContentView` switches on `AuthService.isSignedIn`; ViewModel returns to `signedOut` on sign-out.

**S22 — SettingsRepository local cache**  
Do: last-known `always_confirm`; never block capture on network.  
DoD: offline uses cache.  
Done 15 Aug 2026: `SettingsRepository` + Settings toggle; no Supabase round-trip.

**S23 — Settings sync**  
Do: fetch/upsert `user_settings` under RLS; debounce writes.  
DoD: toggle survives reinstall after sign-in (device + network).  
Done 15 Aug 2026: `SettingsSyncService` fetch + debounced upsert; `user_id` from session only. Reinstall proof needs device.

**S24 — Auth error copy**  
Do: DS voice (cancel / network).  
DoD: no “failed/error” wording.  
Done 15 Aug 2026: `AuthCopy` + Sign-in/Settings facts; previews for not now and connection needed.

### Phase DS

**S25 — Color tokens**  
Do: port `colors.css` ramps + semantic aliases.  
DoD: swatch both modes.  
Done 15 Aug 2026: `MurmurColor` + `ColorTokenCatalog` light/dark previews.

**S26 — Spacing, radius, hit**  
Do: port spacing + radius + hit 44/56/96.  
DoD: layout preview both modes.  
Done 15 Aug 2026: `MurmurSpace`, `MurmurRadius`, `SpaceRadiusCatalog`.

**S27 — Typography**  
Do: bundle OFL Hanken Grotesk + IBM Plex Mono; port type roles.  
DoD: type catalog both modes.  
Done 15 Aug 2026: `Capture/Fonts/`, `MurmurType`, `TypographyCatalog`.

**S28 — Motion + elevation**  
Do: ease-exhale, durations, undo 5s, Reduce Motion; warm shadows.  
DoD: catalog both modes; Reduce Motion.  
Done 15 Aug 2026: `MurmurMotion`, `MurmurElevation`, `MotionElevationCatalog`.

**S29 — Theme + light wash**  
Do: canvas + `.mm-light-wash` (off-centre ember, capture family only).  
DoD: catalog both modes.  
Done 15 Aug 2026: `Theme` / `MurmurLightWash`; capture wash on, sign-in wash off.

**S30 — MurmurIcon**  
Do: SF Symbols wrapper; map kit Lucide names.  
DoD: catalog both modes.  
Done 15 Aug 2026: `MurmurIcon` + `IconCatalog`. Mic mapped but not used on capture home.

**S31 — MurmurButton**  
Do: primary / secondary / ghost; pill; press settle.  
DoD: catalog both modes; one ember primary.  
Done 15 Aug 2026: `MurmurButton` + `ButtonCatalog`; Sign-in Continue with Apple.

**S32 — MurmurIconButton**  
Do: circular 44+ hit; quiet / surface / accent reserved.  
DoD: catalog both modes.  
Done 15 Aug 2026: `MurmurIconButton` + `IconButtonCatalog`; capture Settings.

**S33 — DestinationBadge**  
Do: Reminder vs Event; chip / glyph / quiet; icon + word (glyph keeps the label).  
DoD: catalog both modes.  
Done 15 Aug 2026: `DestinationBadge` + `DestinationBadgeCatalog`.

**S34 — EmptyState, PermissionRow, ToggleRow**  
Do: empty History/first-run; granted/needed (clay, never red); ember settings switch.  
DoD: catalog both modes.  
Done 15 Aug 2026: three components + `SettingsDataCatalog`; Settings confirm row.

**S25–S39** — Port tokens and every design-system component to SwiftUI (colors, space, type, motion, Theme, Icon, Button, IconButton, DestinationBadge, EmptyState/PermissionRow/ToggleRow, DestinationToggle/EditableField, Transcript/SuccessBar, Wordmark/AppIcon, CaptureBloom idle/thinking/done, then listening+level).  
Each session’s DoD: catalog or preview in both modes; Ember ownership; Reduce Motion where motion is involved.

### Phase 0b

**S40** — `Capture` `@Model` per spec §11. No audio. No cloud history id.  
**S41** — ModelContainer + file protection; dummy insert/fetch then remove.  
**S42** — HistoryPurgeService: 72 hours; tests with frozen dates; EventKit untouched.  
**S43** — LoggingPolicy: never log transcript/title/tokens/EventKit IDs.  
**S44** — PermissionsService (device/sim).  
**S45** — Four usage-description strings, warm copy.  
**S46** — PrivacyInfo: account + settings, not “data not collected”.  
**S47–S49** — Onboarding slides 1–3 matching the kit.  
**S50** — Apple as last step; skip later if signed in.

### Phase 1

**S51** — AudioSessionManager.  
**S52–S53** — Speech on-device + stream + ~1.5s silence stop (device).  
**S54** — Unsupported locale, no cloud fallback.  
**S55–S57** — CaptureView idle, live transcript, level → Bloom (device for speech).

### Phase 2

**S58–S62** — ParsedIntent, date extract, taskText cleanup, ~40 phrase tests.  
**S63–S64** — Classification + tests; **stop if default-destination bias is required.**  
**S65–S67** — EventKit create reminder/event; delete-by-id only (device).  
**S68** — End-to-end auto-save (temporary); local history only (device).

### Phase 3

**S69–S72** — Confirmation sheet; edit title/destination/date; Save/Cancel; always-confirm via SettingsRepository.

### Phase 4

**S73–S77** — Synth; clarifying templates; record↔speak one loop; ClarificationView + tap; merge + reclassify once (device for audio).

### Phase 5

**S78–S81** — History list; deep link; swipe delete two options; success + Undo 5s.

### Phase 6

**S82–S87** — App Intent; Siri phrases; widget target (no Supabase in widget); lock screen; Control Center iOS 18+; Back Tap walkthrough (device).

### Phase 7

**S88–S95** — Kit parity, motion, edge copy, icon, Settings/Onboarding polish, a11y.  
**S96** — App Store metadata; **ask monetization**; privacy label matches SECURITY.md.  
**S97** — Hosted Supabase: push migrations, verify RLS, point xcconfig at prod.  
**S98** — TestFlight.

---

## PART 6 — Open decisions

From [CAPTURE_SPEC.md](CAPTURE_SPEC.md) §15: default-destination bias; monetization (before S96); account deletion if App Store requires it; bundle ID if not `app.murmur.capture`. Confirm-before-save default is ON. Name and palette are Murmur / design system.

If a session depends on an unresolved decision, **stop and ask.**
