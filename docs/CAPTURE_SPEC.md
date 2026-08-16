# Murmur — Product spec

> Display name: **Murmur**. Internal types may keep `Capture`.  
> Sessions: [CAPTURE_MASTER_PLAN.md](CAPTURE_MASTER_PLAN.md). Visual/copy: [CAPTURE_DESIGN_BRIEF.md](CAPTURE_DESIGN_BRIEF.md). Security detail: [SECURITY.md](SECURITY.md) (Session 3). Frozen UI kit: [design-system/](design-system/).

If a session hits an **Open Decision** (§15), stop and ask. Do not guess.

---

## 1. What it is

Voice-first iOS capture: tap once, speak a natural task, Murmur files an Apple Reminder or Calendar event. When confidence is low, it asks **one** spoken follow-up (tap fallback on screen). History on this device lasts **3 days**, then the in-app row is deleted; the reminder or event in Apple’s apps remains.

---

## 2. Stack

- Swift 6, SwiftUI, MVVM. Logic in Services/ViewModels, never in Views.
- Min iOS **17.0**. iOS 18+ Control Center is availability-guarded.
- Frameworks: Speech, AVFoundation, NaturalLanguage, Foundation `NSDataDetector`, EventKit, SwiftData, WidgetKit, AppIntents, AuthenticationServices.
- Backend: **Supabase** (Auth + Postgres). Client: official **supabase-swift** only. No other third-party SDKs. No CloudKit. No Foundation Models.
- Speech: `requiresOnDeviceRecognition = true`. No cloud speech fallback.
- Fonts: bundled OFL Hanken Grotesk + IBM Plex Mono (no CDN at runtime).

---

## 3. Data split (locked)

| Place | What |
| --- | --- |
| RAM only | Mic buffers, live transcript, parse workspace |
| SwiftData | `Capture` history rows on this device |
| EventKit | Reminders/events Murmur created (identifiers stored locally only) |
| Supabase | `profiles` + `user_settings` (e.g. `always_confirm`). RLS. |
| Never | Audio files, cloud history, EventKit IDs uploaded, transcripts uploaded |

**History TTL:** delete SwiftData rows with `createdAt < now − 3 days` on launch and after each save. **Do not** EventKit-delete on TTL.

**Auth:** Sign in with Apple → Supabase Auth (native nonce + identity token). Required before the capture loop. Session in Keychain. Settings sync under RLS; last-known settings cached locally so capture is not blocked by network after first sign-in.

Schema and policy text: [SECURITY.md](SECURITY.md) / Session 3. Tables: `profiles.id` = `auth.users.id`; `user_settings.user_id` → `profiles`. Default `always_confirm = true`.

---

## 4. Folder structure (target)

```
Capture/           app (DesignSystem, Models, Services, ViewModels, Views, Intents)
Widgets/           extension — App Group start-capture flag only; no Supabase
supabase/          config + migrations
docs/              this spec, master plan, design brief, SECURITY, design-system
```

---

## 5. State machine

Owned by `CaptureViewModel`.

`signedOut → idle → listening → processing → (clarifying ↔ ) confirming → saving → success` (+ `failed`).

- `signedOut`: Sign in with Apple. Cannot reach capture.
- `idle`: Light Well at rest. History / Settings icon entries.
- `listening`: record mode; live transcript; well follows smoothed level.
- `processing`: thinking well; parse + classify (no record, no speak).
- `clarifying`: speak one question, then listen once (one-loop cap), or tap fallback.
- `confirming`: sheet if `always_confirm` is on, or if the user must review after clarify.
- `saving`: EventKit write + SwiftData insert.
- `success`: Success Bar + Undo for **5 seconds** (design token, not 1.2s).
- `failed`: tertiary fact copy; return to idle. Never the words failed/error.

**Audio golden rule:** the app is either recording **or** speaking, never both. `AudioSessionManager` is the only gate (`enterRecordMode` / `enterPlaybackMode` / `deactivate`).

When `always_confirm` is off and classification is confident, skip `confirming` and auto-save (still show success + Undo).

---

## 6. Parsing and classification

### 6.1 `ParsedIntent`

```
rawTranscript: String
taskText: String              // date phrase and fillers stripped
date: Date?                   // nil if none
hasExplicitTime: Bool         // clock time in the matched substring
durationMinutes: Int?         // from ranges such as 2–3pm; else nil
needsClarification: Bool      // set by classifier or parser (vague/garbled)
clarificationKind: enum?      // date | time | destination | garbled
```

### 6.2 Parsing

1. `NSDataDetector` `.date` on the transcript.
2. `hasExplicitTime`: inspect the **matched substring** for a clock time (hour, am/pm, “noon”, “midnight”, “o’clock”), not merely that `Date` has a time component.
3. `durationMinutes` from a detected range when present.
4. Remove the matched date substring from the text.
5. `NLTagger` strips leading verbs/fillers (“remind me to”, “remember to”, “at”, “on”). Trim.
6. Example: “remind me to call mom tomorrow at 5” → `taskText` “call mom”, date tomorrow 5:00, `hasExplicitTime` true.

Hand-checks: “tomorrow”, “tomorrow at 5”, “Friday 2-3pm”, “next week”, no-date.

### 6.3 Classification (deterministic)

Produce `CaptureDestination` + `confidence` (0…1). If `confidence < 0.5` or `needsClarification`, route to `clarifying`.

| Condition | Destination | Confidence (typical) |
| --- | --- | --- |
| Explicit clock time | `.event` | high (≥ 0.8) |
| Date only, no clock time, no event keyword | `.reminder` *or Open Decision §15* | medium |
| No date, task looks like a to-do | `.reminder` | high |
| Event keywords (“meeting”, “appointment”, “lunch with”, “call with” + time) | `.event` | high if time present, else clarify time |
| Vague time (“soon”, “later”, “sometime”, “this week” without a day) | clarify date/time | &lt; 0.5 |
| Garbled / empty taskText | clarify | &lt; 0.5 |
| Ambiguous weekday (“Friday” when two Fridays could apply — use NSDataDetector’s date; if two dates in text) | clarify | &lt; 0.5 |

**Open Decision:** default-destination bias when a **date exists, no time, no keyword**. Do not invent a bias in code; stop and ask in Session 63 if still unresolved. Until then, implement the table rows that are unambiguous; for the ambiguous row, flag clarification rather than guessing.

Default event duration when creating an `EKEvent` without `durationMinutes`: **60 minutes**.

---

## 7. Clarification

One loop maximum. Then fall through to confirmation (user can fix fields by tap).

Templates (spoken + on-screen; DS voice):

- Missing when: “When should this be?”
- Missing time (event-like, date known): “What time?”
- Destination unclear: “Should this go to Reminders, or Calendar?”
- Two dates: “Which day did you mean — Friday or Saturday?”
- Garbled: “Say that again, or tap to type it.”

Quiet-mode copy: “Somewhere quiet? Tap an answer instead.”

Merge: parse the **answer scoped to the missing field**, merge into pending `ParsedIntent`, classify **once**, then `confirming`.

---

## 8. Quick-launch

- `QuickCaptureIntent`: `openAppWhenRun = true`; on foreground, enter `listening` if signed in (if signed out, sign-in first).
- `AppShortcutsProvider`: natural phrases (quick capture / murmur).
- Lock-screen accessory widget: launches the intent (foreground + unlock).
- Control Center `ControlWidget`: iOS 18+ only.
- Back Tap: Settings walkthrough (Accessibility → Touch → Back Tap) wrapping the Shortcut/intent. User installs; app does not silently change system Accessibility.
- Widget App Group: **start-listening flag only**. No history, no tokens, no Supabase in the extension.

---

## 9. Permissions

Request after onboarding priming (why, not system jargon). iOS 17 full-access APIs for Calendar and Reminders.

| Key | Purpose |
| --- | --- |
| `NSSpeechRecognitionUsageDescription` | On-device transcription |
| `NSMicrophoneUsageDescription` | Hear the capture |
| `NSCalendarsFullAccessUsageDescription` | Create/open/delete **Murmur-created** events |
| `NSRemindersFullAccessUsageDescription` | Create/open/delete **Murmur-created** reminders |

Never enumerate the user’s whole calendar or reminder library into the UI. Delete/update only by stored identifier.

Warm copy is written in Session 45; tone from the design brief.

---

## 10. EventKit

- Create `EKReminder` (title, optional due date) or `EKEvent` (title, start, duration or 60m).
- Persist `calendarItemIdentifier` (or equivalent) on the SwiftData `Capture`.
- Deep link: open that item in Reminders or Calendar.
- Swipe delete: “Delete from Murmur only” vs “Also delete the reminder/event”.
- Undo: delete EventKit item **and** SwiftData row.
- TTL: SwiftData only.

---

## 11. SwiftData `Capture` model

No audio blob. No Supabase id for history.

| Field | Notes |
| --- | --- |
| `id` | UUID |
| `title` | Cleaned `taskText` |
| `destination` | reminder \| event |
| `startDate` | Optional |
| `hasExplicitTime` | Bool |
| `durationMinutes` | Optional |
| `eventKitIdentifier` | Optional string; opaque |
| `createdAt` | TTL clock |
| `updatedAt` | |

Do not store raw transcripts beyond `title` unless a later session explicitly adds a field.

---

## 12. Edge cases (graceful copy, no “error”)

| Case | Behaviour |
| --- | --- |
| No speech / silence stop with empty text | Tertiary: nothing captured; stay or return idle |
| Permission not granted | PermissionRow “Not allowed yet” + Open Settings |
| Locale without on-device speech | Explain; do not fall back to network recognition |
| Past date | Allow, or confirm — show the date clearly; do not shout |
| Garbled | Clarification loop then confirm |
| Network down at first Apple sign-in | Need a connection to create the account; DS voice |
| Network down later | Capture works; settings use cache; sync when back |
| History empty / all rows aged out | Empty state; 3-day memory, not an archive |
| EventKit write problem | Tertiary fact; do not leave a half-saved SwiftData row without identifier if save did not complete — prefer atomic: EventKit then local row |

---

## 13. Settings (synced)

- `always_confirm` (default **on**): cloud + local cache.
- Live permission status + Open Settings.
- Sign out (clears Keychain session; local history remains on device until TTL or user delete).
- Hands-free / Back Tap walkthrough entry.

---

## 14. Onboarding

1. What it does.  
2. Permission priming.  
3. Optional hands-free note.  
4. Continue with Apple.

Fresh install shows this; subsequent launches skip if signed in. First-run capture empty state after that.

---

## 15. Open decisions

- Final App Store name: **Murmur** (design-system lead) unless you change it.
- Palette/type: locked to the design system (Hanken bundled).
- **Default-destination bias** (date, no time, no keyword): unresolved.
- Confirm-before-save default: **ON**.
- Monetization: before Session 96.
- Account deletion UI: not v1 unless App Store requires it before submit.
- Bundle ID: `app.murmur.capture` unless you supply one (must match Sign in with Apple).

---

## 16. Test notes

Speech, EventKit, Sign in with Apple, Siri, lock-screen widget, Back Tap: **device**, not Simulator as source of truth.
