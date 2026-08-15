The only control type in Settings. Stack them inside a raised group with hairline dividers.

```jsx
<ToggleRow label="Speak questions aloud" description="Murmur asks out loud when it needs one more detail." checked={speak} onChange={setSpeak} />
```

Switch track is ember when on, `--line-soft` when off. Set `divider={false}` on the last row of a group.
