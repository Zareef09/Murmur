The hero of the app: one element that carries idle → listening → thinking → done without a screen change.

```jsx
<CaptureBloom state="listening" level={amp} onTap={toggle} label="Listening" />
```

Rules: exactly one per screen; it owns the accent color, so nothing else on the capture screen may use ember. Feed `level` a smoothed amplitude — raw values make it read as a meter instead of a breath. Never place a text label inside it.
