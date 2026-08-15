# Murmur — iOS UI kit

A click-through recreation of the whole app at 393×852 (iPhone 15/16 logical size), portrait, one-handed.

- `index.html` — the interactive kit. Left rail lists every screen and state; the phone is live. Query params: `?screen=<id>&theme=light|dark&chrome=0` (chrome=0 renders the bare frame and freezes the auto-advance, for embedding).
- `gallery.html` — every state, light and dark, side by side, as live frames.

## Files

| File | Contains |
| --- | --- |
| `Phone.jsx` | `Phone` device frame, `StatusBar` (Dynamic Island), `NavBar`, `HomeIndicator`, `Group` (grouped-list container) |
| `CaptureScreen.jsx` | Capture home in all five states + `useLevel` (simulated smoothed amplitude) |
| `ConfirmSheet.jsx` | Confirmation sheet, confident and correcting; `DateWheel` (skin over the system picker) |
| `ClarifyScreen.jsx` | Spoken Q&A with tap-to-answer fallback |
| `ListScreens.jsx` | History (populated / empty, swipe-to-delete) and Settings |
| `OnboardingScreen.jsx` | Three onboarding slides + `SpringboardScreen` (Home Screen with the app icon) |
| `App.jsx` | State machine, theme toggle, state rail |

## Flow

Onboarding → first run → idle. Tapping the well starts listening; after ~4.6s it moves to thinking, then the Confirmation sheet rises. Saving drops to the success state with Undo, which settles back to idle after 5s. History and Settings are quiet icon entries in the top bar.

Everything visual comes from the design-system components and tokens — no local color, type or radius values.
