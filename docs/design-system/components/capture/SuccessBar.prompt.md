The confirmation after a save — a settle, not a celebration. No confetti, no full-screen success state.

```jsx
<SuccessBar message="Saved to Reminders · tomorrow 5:00 PM" destination="reminder" onUndo={undo} />
```

Sits just above the safe area on Capture, fades in over 380ms, and leaves after `--undo-window` (5s). Undo is a ghost action; it never competes with the capture element.
