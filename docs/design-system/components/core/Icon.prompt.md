Monochrome glyph that inherits `currentColor`; use it for every icon in Murmur rather than inline SVG.

```jsx
<Icon name="bell" size={20} title="Reminder" />
<Icon name="chevron-right" size={18} style={{ color: 'var(--text-tertiary)' }} />
```

Icons resolve to `assets/icons/<name>.svg`. Set `window.MURMUR_ICON_BASE` once per page to the correct relative path (e.g. `'../../assets/icons'`). Never pair an icon with color as the only signal — Reminder vs Event always carries icon **and** label.
