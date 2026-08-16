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
- [x] S35 — DestinationToggle + EditableField — two destinations; empty is “No date”; catalog.
- [x] S36 — TranscriptView + SuccessBar — wrap, never truncate; Undo ghost; 5s window owned by parent.
- [x] S37 — Wordmark + AppIconView — lowercase murmur + ember dot; icon is the well, not a mic.
- [x] S38 — CaptureBloom idle / thinking / done — breath, hold+arc, settle+check. Listening is S39.
- [x] S39 — CaptureBloom listening + level — lagged rings; 120/400ms follow; catalog sim, no mic yet.

**Phase 0b — Persistence, permissions, onboarding**

- [x] S40 — SwiftData `Capture` model — spec fields; no audio; no cloud history id.
- [x] S41 — ModelContainer + file protection — complete-until-first-unlock; no CloudKit; probe insert/fetch/delete.
- [x] S42 — HistoryPurgeService (3 days) — 72h `createdAt`; EventKit untouched; frozen-date tests.
- [x] S43 — LoggingPolicy — typed os.Logger events; no transcript/title/tokens/EventKit IDs.
- [x] S44 — PermissionsService — mic, speech, reminders, calendar; fullAccess only; no EventKit listing. Needs device.
- [x] S45 — Info.plist permission strings — four why-copy usage descriptions; no error/failed/!.
- [x] S46 — PrivacyInfo.xcprivacy — User ID + product interaction; no tracking; UserDefaults CA92.1.
- [x] S47 — Onboarding slide 1 — “Say it once. It’s kept.” Idle well; Next; not gated yet.
- [x] S48 — Onboarding slide 2 — permission priming; Allow access; kit rows. Needs device for sheets.
- [x] S49 — Onboarding slide 3 — hands-free Action Button note; AppIcon; Set it up (walkthrough S87).
- [x] S50 — Onboarding + Apple + first-launch gate — slides then Sign in; skip slides if signed in.

**Phase 1 — Transcribe**

- [x] S51 — AudioSessionManager — record or playback, never both; deactivate between.
- [x] S52 — SpeechService (on-device request) — `requiresOnDeviceRecognition = true`; no cloud fallback.
- [x] S53 — SpeechService stream + silence stop — RAM buffers; ~1.5s after last voice. Needs device.
- [x] S54 — Unsupported locale path — copy + no cloud request; `zz` locale tests. Device for a real unsupported language.
- [x] S55 — CaptureView idle — Light Well 240, quiet History/Settings, “Tap to speak”. Tap/listen is S56.
- [x] S56 — Live transcript wiring — tap well → listen; TranscriptView; silence → idle. Needs device.
- [x] S57 — Audio-level → Bloom — normalised RMS 0…1; Bloom attack/release. Needs device.

**Phase 2 — Parse, classify, save**

- [x] S58 — ParsedIntent & CaptureDestination — spec fields; reminder | event; no parse yet.
- [x] S59 — ParsingService: date extraction — NSDataDetector; clock time on substring; range duration.
- [x] S60 — ParsingService: taskText cleanup — drop date phrase + remind/remember frame; NLTagger.
- [x] S61 — Parsing tests A — 20 phrases: no-date, tomorrow, clock time, two dates, garbled date-only.
- [x] S62 — Parsing tests B — 20 more phrases + empty transcript; still no destination.
- [x] S63 — ClassificationService — unambiguous rows; date-only no-keyword asks destination (no bias).
- [x] S64 — Classification tests — wider table + parse-then-classify; still no destination bias.
- [x] S65 — EventKitService: Reminder — title + optional due; no library listing. Needs device.
- [x] S66 — EventKitService: Event — title, start, duration or 60m; default calendar. Needs device.
- [x] S67 — EventKit delete-by-id only — `calendarItem(withIdentifier:)`; no library listing. Needs device.
- [x] S68 — Wire pipeline auto-save (temporary) — parse → classify → EventKit then SwiftData + purge. Needs device.

**Phase 3 — Confirmation**

- [x] S69 — ConfirmationView (read-only)
- [x] S70 — Inline edit: title + destination
- [x] S71 — Inline edit: date/time
- [x] S72 — Confirm/cancel + always-confirm toggle

**Phase 4 — Voice clarification**

- [x] S73 — SpeechSynthService
- [x] S74 — clarifying state + question templates
- [x] S75 — record↔speak handoff + one-loop cap
- [x] S76 — ClarificationView + tap fallback
- [x] S77 — Merge answer → re-classify once

**Phase 5 — History**

- [x] S78 — HistoryView list + row
- [x] S79 — Deep-link to Reminders/Calendar
- [x] S80 — Swipe delete (app-only vs also-external)
- [x] S81 — Success + Undo

**Phase 6 — Quick-launch**

- [x] S82 — QuickCaptureIntent
- [x] S83 — Siri phrases (AppShortcutsProvider)
- [x] S84 — Widget extension target
- [x] S85 — Lock-screen accessory widget
- [x] S86 — Control Center control (iOS 18+)
- [x] S87 — Back Tap shortcut + onboarding setup

**Phase 7 — Polish and ship**

- [x] S88 — Capture screen parity
- [x] S89 — Remaining screens parity
- [x] S90 — Motion polish
- [x] S91 — Empty states + edge copy
- [x] S92 — App icon assets
- [x] S93 — Settings final polish
- [x] S94 — Onboarding final polish
- [x] S95 — Accessibility pass
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

**S35 — DestinationToggle + EditableField**  
Do: Reminder ↔ Event (icon + word + tint); tap-to-edit rows; empty is a calm placeholder.  
DoD: catalog both modes. Not wired into Settings (default destination is an open decision).  
Done 15 Aug 2026: `DestinationToggle`, `EditableField`, `FieldsCatalog`.

**S36 — TranscriptView + SuccessBar**  
Do: live caption (settled + partial); success settle with Undo; no confetti.  
DoD: catalog both modes. Not wired into Capture home yet (S55–S57 / S81).  
Done 15 Aug 2026: `TranscriptView`, `SuccessBar`, `CaptureFeedbackCatalog`.

**S37 — Wordmark + AppIconView**  
Do: lowercase `murmur` + ember dot; in-app icon geometry (not a mic).  
DoD: catalog both modes.  
Done 15 Aug 2026: `Wordmark`, `AppIconView`, `BrandCatalog`; Sign-in uses `Wordmark`.

**S38 — CaptureBloom idle / thinking / done**  
Do: Light Well morph; idle 3.8s breath; thinking hold + rim arc; done core + check. Caption under, never inside.  
DoD: catalog both modes; Reduce Motion holds still. Not on Capture home yet (S55).  
Done 15 Aug 2026: `CaptureBloom` + `CaptureBloomCatalog`.

**S39 — CaptureBloom listening + level**  
Do: bloom opens with amplitude; rings lag 0 / 90 / 180ms; smooth ~120ms attack / ~400ms release.  
DoD: catalog both modes; not a meter; Reduce Motion snaps. Mic tap is S57.  
Done 15 Aug 2026: `listening` + `level` on `CaptureBloom`; catalog uses a simulated wave.

**S25–S39** — Port tokens and every design-system component to SwiftUI (colors, space, type, motion, Theme, Icon, Button, IconButton, DestinationBadge, EmptyState/PermissionRow/ToggleRow, DestinationToggle/EditableField, Transcript/SuccessBar, Wordmark/AppIcon, CaptureBloom idle/thinking/done, then listening+level).  
Each session’s DoD: catalog or preview in both modes; Ember ownership; Reduce Motion where motion is involved.

### Phase 0b

**S40 — `Capture` SwiftData model**  
Do: spec §11 fields + `createdAt` for TTL. No audio. No cloud history id.  
DoD: compiles.  
Done 15 Aug 2026: `Capture/Models/Capture.swift`; `CaptureDestination` is `Codable`.

**S41 — ModelContainer + file protection**  
Do: on-device store; complete-until-first-unlock; dummy insert/fetch then remove.  
DoD: boots clean.  
Done 15 Aug 2026: `Persistence` + `MurmurApp.modelContainer`; SECURITY.md notes the protection choice.

**S42 — HistoryPurgeService (3 days)**  
Do: delete SwiftData rows older than 72 hours on launch and after save. Never EventKit-delete on TTL.  
DoD: old rows gone; EventKit untouched; frozen-date tests.  
Done 15 Aug 2026: `HistoryPurgeService` + `saveAndPurgeHistory`; `MurmurTests`.

**S43 — LoggingPolicy**  
Do: os.Logger wrapper; never log transcript/title/tokens/EventKit IDs.  
DoD: settings upsert uses it; tests cover allowed vs banned shapes.  
Done 15 Aug 2026: `LoggingPolicy`; SettingsSyncService; `LoggingPolicyTests`.

**S44 — PermissionsService**  
Do: Speech, Mic, Calendar, Reminders (iOS 17 full access). No EventKit library listing.  
DoD: status mapping tests; system prompts need S45 strings (skipped until then so the app does not crash). Device for real grants.  
Done 15 Aug 2026: `PermissionsService`; `PermissionsServiceTests`.

**S45 — Info.plist usage strings**  
Do: four warm why-copy strings (mic, speech, reminders, calendar).  
DoD: keys present; no error/failed/!.  
Done 15 Aug 2026: `Capture/Info.plist`; `UsageDescriptionTests`.

**S46 — PrivacyInfo.xcprivacy**  
Do: account + settings; not “data not collected”; no tracking.  
DoD: manifest in the app bundle.  
Done 15 Aug 2026: `Capture/PrivacyInfo.xcprivacy`; `PrivacyManifestTests`.

**S47 — Onboarding slide 1**  
Do: what it does; kit copy; idle Light Well.  
DoD: light + dark preview. Not first-launch gated (S50).  
Done 15 Aug 2026: `OnboardingView` slide 1.

**S48 — Onboarding slide 2**  
Do: permission priming; kit copy; Microphone / Reminders / Calendar rows; Allow access.  
DoD: light + dark preview. Device for system sheets.  
Done 15 Aug 2026: slide 2 in `OnboardingView`; Next from slide 1.

**S49 — Onboarding slide 3**  
Do: optional hands-free note; kit copy; app icon; Set it up (no silent Accessibility change).  
DoD: light + dark preview. Walkthrough is S87.  
Done 15 Aug 2026: slide 3 in `OnboardingView`.

**S50 — Onboarding + Apple + first-launch gate**  
Do: slides then Continue with Apple; later launches skip slides if signed in.  
DoD: fresh install → slides → Sign in → capture; signed-in relaunch skips slides.  
Done 15 Aug 2026: `OnboardingGate`; `ContentView` gate; restore waits before routing.

### Phase 1

**S51 — AudioSessionManager**  
Do: `enterRecordMode` / `enterPlaybackMode` / `deactivate`; never both.  
DoD: tests prove deactivate between modes.  
Done 15 Aug 2026: `AudioSessionManager` + `AudioSessionManagerTests`.

**S52 — SpeechService on-device request**  
Do: `SFSpeechAudioBufferRecognitionRequest` with `requiresOnDeviceRecognition = true`. Never cloud fallback.  
DoD: request flag stays true; stream/silence is S53.  
Done 15 Aug 2026: `SpeechService` + `SpeechRecognitionPolicyTests`.

**S53 — SpeechService stream + silence stop**  
Do: audio tap → on-device request; stop ~1.5s after last voice; no audio on disk.  
DoD: silence unit tests; live listen needs device.  
Done 15 Aug 2026: `SilenceWatch` + engine tap; `SilenceWatchTests`.

**S54 — Unsupported locale, no cloud fallback**  
Do: if the locale cannot run on-device speech, explain; never set `requiresOnDeviceRecognition` false.  
DoD: copy is a fact (no error/failed/!); unavailable locale yields no request. Device for a real language.  
Done 15 Aug 2026: `SpeechCopy` + `SpeechLocalePolicy`; Capture caption; `SpeechCopyTests`.

**S55 — CaptureView idle**  
Do: Light Well at rest (240); History + Settings quiet icons; caption under the well; ember only on the well.  
DoD: light + dark idle; no live transcript (S56); no mic level (S57).  
Done 15 Aug 2026: `CaptureView` kit chrome; History icon lands on a stub (`HistoryView` list is S78).

**S56 — Listening + live transcript**  
Do: tap well → record mode + on-device stream; `TranscriptView` above the well; silence ends the turn. Bloom listening, level stays 0.  
DoD: unit tests for start / empty silence / permission; live listen needs device. No parse (S58).  
Done 15 Aug 2026: `CaptureViewModel.tapWell`; `SpeechService` turn callbacks; listening previews.

**S57 — Audio-level → Bloom**  
Do: tap RMS → 0…1; feed `CaptureBloom.level` while listening. Bloom already smooths (120/400ms). Never store audio.  
DoD: unit tests for floor/peak mapping; live well needs device.  
Done 15 Aug 2026: `SpeechEnergy.normalizedLevel`; `listenLevel` on the view model.

### Phase 2

**S58 — ParsedIntent & CaptureDestination**  
Do: spec §6.1 fields; destination is reminder or event only. No date extract (S59). No default-destination bias.  
DoD: types compile; field tests; not wired to listen yet.  
Done 15 Aug 2026: `ParsedIntent`, `ClarificationKind`; `CaptureDestination` CaseIterable; `ParsedIntentTests`.

**S59 — ParsingService: date extraction**  
Do: `NSDataDetector` `.date`; `hasExplicitTime` from the matched substring; `durationMinutes` from a range. Do not strip fillers (S60).  
DoD: tomorrow / at 5 / no-date tests; two dates → clarify date.  
Done 15 Aug 2026: `ParsingService` + `ClockTimePhrase`; `ParsingServiceDateTests`.

**S60 — ParsingService: taskText cleanup**  
Do: remove matched date substring; NLTagger + frame words (“remind me to”, “remember to”, leftover at/on). Trim.  
DoD: spec example → `call mom`; empty remainder is garbled, not a guessed title. Phrase corpus is S61–S62.  
Done 15 Aug 2026: `TaskTextCleanup`; `ParsingServiceCleanupTests`.

**S61 — Parsing tests A**  
Do: first ~20 phrases (no date, tomorrow, clock time, ranges, two dates, date-only garbled). No destination.  
DoD: corpus A passes.  
Done 16 Aug 2026: `ParsingPhraseTestsA`.

**S62 — Parsing tests B**  
Do: remaining ~20 phrases (mid-sentence date, midnight/noon, weekdays, empty). No destination.  
DoD: corpus A + B ≈ 40 phrases.  
Done 16 Aug 2026: `ParsingPhraseTestsB`; shared `PhraseCase`.  
**S63 — ClassificationService**  
Do: spec §6.3 unambiguous rows. Date + no time + no keyword → clarify destination (open decision; do not guess).  
DoD: clock time → event; no date → reminder; date-only asks destination.  
Done 16 Aug 2026: `ClassificationService`; `destination` + `confidence` on `ParsedIntent`.

**S64 — Classification tests**  
Do: wider §6.3 table; parse-then-classify spoken phrases. Do not invent a date-only bias.  
DoD: reminder / event / time / destination / date / garbled rows pass.  
Done 16 Aug 2026: `ClassificationTableTests`.  
**S65 — EventKitService: Reminder**  
Do: `EKReminder` title + optional due; date-only has no fake clock; `calendarItemIdentifier` returned, never logged. Default reminder calendar only.  
DoD: due-component tests; unauthorized throws; live save needs device. Events are S66.  
Done 16 Aug 2026: `createReminder`; `ReminderDue`; `EventKitCopy`.

**S66 — EventKitService: Event**  
Do: `EKEvent` title, start, duration or 60m; default calendar for new events; identifier returned, never logged.  
DoD: span tests; unauthorized throws; live save needs device. Delete is S67.  
Done 16 Aug 2026: `createEvent`; `EventSpan`; `eventCreated` log.

**S67 — EventKit delete-by-id only**  
Do: remove only `calendarItem(withIdentifier:)`. Never enumerate calendars/reminders. Empty id does not scan. Missing item is a no-op. Never log the id.  
DoD: empty-id test; live delete needs device.  
Done 16 Aug 2026: `deleteItem`; `itemDeleted` log.

**S68 — Wire pipeline auto-save (temporary)**  
Do: after silence, parse + classify; if confident, EventKit then SwiftData + purge. Skip confirmation (S69). Clarify kinds are tertiary facts, not the spoken loop.  
DoD: reminder/event save tests; EventKit failure leaves no history row; live save needs device.  
Done 16 Aug 2026: `finishCapture` on `CaptureViewModel`; `ClarifyCopy`.

### Phase 3

**S69 — ConfirmationView (read-only)**  
Do: kit sheet; fields display title / when / destination; no inline edit. Confident captures stop here; Save files EventKit then history. Cancel drops the turn. `alwaysConfirm` skip is S72.  
DoD: reminder/event confirm-then-save tests; cancel leaves no row; When formatter; live save needs device.  
Done 16 Aug 2026: `ConfirmationView`; `ConfirmationCopy`; `pendingIntent` on the view model.

**S70 — Inline edit: title + destination**  
Do: tap title to type; tap Goes to for Reminder/Event toggle. One field at a time. Headline “Fix it up” while editing. When is S71.  
DoD: edited title saves; destination override saves the chosen kind; When still display-only.  
Done 16 Aug 2026: `ConfirmationEditField`; title TextField + `DestinationToggle` on the sheet.

**S71 — Inline edit: date/time**  
Do: When row opens a system wheel DatePicker (Murmur tint). Reminders: date-only, include time, or No date. Events always have a clock.  
DoD: date-only reminder due; edited event start; opening-seed tests. Live picker on device.  
Done 16 Aug 2026: `ConfirmationWhenEditor`; `ConfirmationWhenEdit`.

**S72 — Save / Cancel + always-confirm**  
Do: Settings toggle reads/writes SettingsRepository (sync via S23). Off + confident → skip sheet, EventKit then history. On → confirmation. Unsure still asks. Success bar is S81.  
DoD: skip-sheet save test; unsure still no save; toggle writes cache.  
Done 16 Aug 2026: `finishCapture` honors `alwaysConfirm`; `FakeSettingsSync`.

### Phase 4

**S73 — SpeechSynthService**  
Do: `AVSpeechSynthesizer` via playback mode only; deactivate after. Never log the utterance. Empty text is a no-op.  
DoD: playback then deactivate tests; empty skips audio; log has no words. Live speak needs device.  
Done 16 Aug 2026: `SpeechSynthService` + `SystemSpeechUtterer`; `SpeechSynthServiceTests`.

**S74 — clarifying state + question templates**  
Do: unsure parses enter `.clarifying` with spec questions (incl. two weekdays). Quiet-mode hint copy. Do not speak or listen yet (S75).  
DoD: template tests; date-only goes to clarifying, not idle; always-confirm off still clarifies.  
Done 16 Aug 2026: `ClarifyCopy.question`; `ClarifyWeekdays`; pending intent kept.

**S75 — record↔speak + one-loop cap**  
Do: speak the question (playback), then listen once (record). Never both. A spoken answer goes to confirmation (merge is S77). Empty answer stays clarifying without a second question.  
DoD: speak-then-listen test; no second synth; live audio needs device.  
Done 16 Aug 2026: `speakThenListen`; `clarificationAnswer`; `FakeSpeechSynth`.

**S76 — ClarificationView + tap fallback**  
Do: kit screen; quiet hint; tap chips when the choice is obvious (destination, two weekdays, today/tomorrow); Start over. Merge is S77.  
DoD: tap fallback reaches confirmation; start over returns idle.  
Done 16 Aug 2026: `ClarificationView`; `tapClarificationAnswer`; `startOver`.

**S77 — Merge answer → re-classify once**  
Do: parse the answer for the missing field only; merge into the pending intent; classify once; always show confirmation (even if confirm-before-save is off). Do not ask a second question. Do not invent reminder vs calendar.  
DoD: destination/date/time/garbled merge tests; after clarify the sheet always appears; chosen destination is kept.  
Done 16 Aug 2026: `ClarificationMerge`; classify keeps a user-chosen destination.

### Phase 5

**S78 — HistoryView list + row**  
Do: `@Query` newest-first; kit HistoryRow; Today / Yesterday groups; empty state (3-day memory, not an archive). Open is S79. Swipe delete is S80.  
DoD: empty kit copy; newest-first groups; live list needs a saved capture.  
Done 16 Aug 2026: `HistoryView`; `HistoryRow`; `HistoryListFormat`.

**S79 — Deep-link to Reminders/Calendar**  
Do: tap a history row; look up only the stored identifier; open Calendar (`calshow`) or Reminders. Missing item → quiet fact. Never log the identifier. Device.  
DoD: URL builders omit identifiers; empty/unknown id does not scan the library; live open needs device.  
Done 16 Aug 2026: `EventKitDeepLink`; `openingURL`; History row tap.

**S80 — Swipe delete (app-only vs also-external)**  
Do: kit swipe reveals clay trash; confirm “Delete from Murmur only” vs “Also delete the reminder/event”. Murmur-only drops SwiftData. Also-external deletes EventKit by stored id first, then the row. EventKit failure keeps the row.  
DoD: murmur-only does not call EventKit; also-external deletes both; failure leaves the row. Live swipe on device.  
Done 16 Aug 2026: `HistoryDelete`; swipe + confirmationDialog.

**S81 — Success + Undo 5s**  
Do: after save, `.success` + SuccessBar; bloom “Saved”; Undo 5s (`MurmurMotion.undoWindow`). Undo deletes EventKit and the history row. Window expiry keeps the save. Always-confirm off still shows success.  
DoD: success then idle after the window; undo removes both; copy has no celebration.  
Done 16 Aug 2026: `SuccessCopy`; `undoSave`; Capture home SuccessBar.

### Phase 6

**S82 — QuickCaptureIntent**  
Do: `openAppWhenRun = true`; arm a start-listening flag; on foreground listen if signed in; if signed out, sign-in first (flag stays). No App Group yet (S84). Siri phrases are S83.  
DoD: flag is a bool only; signed-in idle starts listening; signed-out leaves the flag; live Shortcuts need device.  
Done 16 Aug 2026: `QuickCaptureFlag`; `applyQuickCaptureIfPending`.

**S83 — Siri phrases (AppShortcutsProvider)**  
Do: donate natural phrases for quick capture / Murmur. Each phrase includes the app name. No widget yet.  
DoD: one donated shortcut; live “Hey Siri” needs device.  
Done 16 Aug 2026: `CaptureShortcuts` phrases.

**S84 — Widget extension target**  
Do: `Widgets/` target; App Group `group.app.murmur.capture`; start-listening flag only; no supabase-swift in the extension. Lock-screen families are S85.  
DoD: Murmur embeds MurmurWidgets; flag uses the App Group; widget has no Supabase. Device: enable the App Group on the team.  
Done 16 Aug 2026: `MurmurWidgets`; `Shared/QuickCaptureFlag`; App Group entitlements.

**S85 — Lock-screen accessory widget**  
Do: circular / inline / rectangular accessories; tap runs Quick capture (foreground + unlock). Waveform, not mic. Control Center is S86.  
DoD: lock-screen families compiled; live add-to-Lock-Screen needs device.  
Done 16 Aug 2026: accessory families on `QuickCaptureWidget`.

**S86 — Control Center control (iOS 18+)**  
Do: `ControlWidget` + `ControlWidgetButton` → Quick capture; waveform, not mic; `#available` so iOS 17 home/lock widgets still load.  
DoD: compiles on iOS 17 deployment; Control Center add is device / iOS 18.  
Done 16 Aug 2026: `QuickCaptureControl`; WidgetBundle split iOS 17 vs 18.

**S87 — Back Tap walkthrough**  
Do: in-app steps Accessibility → Touch → Back Tap wrapping Quick capture; Action Button note; onboarding Set it up + Settings Hands-free. Never write system Accessibility.  
DoD: walkthrough compiles; live Back Tap assignment needs device.  
Done 16 Aug 2026: `BackTapWalkthroughView`; Settings + onboarding entry.

### Phase 7

**S88 — Capture screen parity**  
Do: kit first-run / idle / listening / thinking / success+Undo; Light Well 240 owns Ember; History/Settings chrome. Remaining screens are S89.  
DoD: previews for those states; live well still needs device.  
Done 16 Aug 2026: `CaptureCopy` first-run; reserved SuccessBar slot.

**S89 — Remaining screens parity**  
Do: sign-in, confirmation (120 well), clarification listening/answered, history, settings account row (no email/id). Permissions Open Settings is S93. Motion is S90.  
DoD: light + dark previews on those screens.  
Done 16 Aug 2026: kit layout + `SettingsCopy` account row.

**S90 — Motion polish**  
Do: storyboard beats — idle→listening 620ms, thinking→done settle, confirm 380ms / 40pt / 0.985 / 8% dim, sheet exit 300ms, field stagger 40ms, Reduce Motion 1ms. No springs.  
DoD: tokens tested; live morph needs device.  
Done 16 Aug 2026: `MurmurMotion` storyboard constants; confirm scale/dim; breath freeze; haptics.

**S91 — Empty states + edge copy**  
Do: spec §12 facts — silence, permissions, locale, past date, garbled, Apple connection, settings cache, history 3-day empty, EventKit needed. No error/failed/invalid/!.  
DoD: copy tests; Open Settings affordance is S93.  
Done 16 Aug 2026: `HistoryCopy.ttlNote`; `ConfirmationCopy.pastDay`; `SettingsCopy.usingThisPhone`.

**S92 — App icon assets**  
Do: 1024 Home Screen / App Store well (light, dark, tinted); not a microphone; opaque marketing icons.  
DoD: `AppIcon.appiconset` PNGs compile; Home Screen look needs device.  
Done 16 Aug 2026: `Scripts/GenerateAppIcon.swift`; light/dark/tinted 1024.

**S93 — Settings final polish**  
Do: confirm toggle (already wired); live permission rows; Open Settings after a needed request; sign out. Do not add a default destination (open decision). Speak-questions is kit-only, not spec.  
DoD: Settings shows mic, speech, reminders, calendar; needed rows use “Open Settings”; returning from Settings.app refreshes.  
Done 16 Aug 2026: `SettingsCopy` permission strings; `PermissionRow.fixTitle`; Settings permissions group.

**S94 — Onboarding final polish**  
Do: kit tone; live permission priming; Open Settings if still needed; Continue to leave without all grants; Set it up still opens the walkthrough (Skip still skips).  
DoD: three slides + Skip → Apple; denied access stays on slide 2 until Continue or Skip.  
Done 16 Aug 2026: `OnboardingAccess`; live rows; Continue CTA after ask.

**S95 — Accessibility pass**  
Do: Dynamic Type (relative fonts, no clipped history/empty copy); AA for body + destination chips both modes; VoiceOver labels/hints; destination never color-only; well hit ≥ 96 when tappable.  
DoD: tests for hit, contrast, destination copy; VO walkthrough needs device.  
Done 16 Aug 2026: `AccessibilityCopy`; `CaptureBloom.isInteractive` + hit 96; button sm ≥ 44; history VO + DT; contrast tests.

**S96** — App Store metadata; **ask monetization**; privacy label matches SECURITY.md.  
**S97** — Hosted Supabase: push migrations, verify RLS, point xcconfig at prod.  
**S98** — TestFlight.

---

## PART 6 — Open decisions

From [CAPTURE_SPEC.md](CAPTURE_SPEC.md) §15: default-destination bias; monetization (before S96); account deletion if App Store requires it; bundle ID if not `app.murmur.capture`. Confirm-before-save default is ON. Name and palette are Murmur / design system.

If a session depends on an unresolved decision, **stop and ask.**
