Permission status in Settings and during onboarding.

```jsx
<PermissionRow label="Microphone" status="granted" />
<PermissionRow label="Calendar" status="needed" hint="Needed to save events" onFix={ask} divider={false} />
```

Needs-attention uses clay (`--attention-fg`), which is warm and low-alarm by design. Never red, never an exclamation-only signal — the sub-line always says what is missing.
