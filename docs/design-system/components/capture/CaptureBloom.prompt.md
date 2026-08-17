The hero of the app: one element that carries idle → listening → thinking → done without a screen change. A bead of iridescent glass inside a guilloché lattice, ringed by a single ember→violet arc.

```jsx
<CaptureBloom state="listening" level={amp} onTap={toggle} label="Listening" />
```

The arc is the only progress signal on the screen — it extends with `level` while listening, detaches into a travelling sweep while thinking, and closes at 360° on success. The lattice is the listening field: it brightens with voice, never scales. The bead's film comes from wide gradients turning at incommensurable rates (26s / 37s / 19s) under `--iris-blend`; the breath is asymmetric — short inhale, held top, long exhale, at `--dur-breath` (5.2s). Don't retime a single layer; change the token.

Rules: exactly one per screen; it owns both the accent and the iridescence tokens, so nothing else on the capture screen may use ember or `--iris-*`. Feed `level` a smoothed amplitude — raw values make it read as a meter instead of a breath. Never place a text label inside it.
