The action button; one `primary` per screen at most, everything else `secondary` or `ghost`.

```jsx
<Button variant="primary" fullWidth onClick={save}>Save reminder</Button>
<Button variant="ghost" size="md">Cancel</Button>
```

Pill radius always. Press state is a 1.8% settle, no bounce, no shadow. Destructive actions do not get a red fill — use `ghost` with `style={{ color: 'var(--attention-fg)' }}`.
