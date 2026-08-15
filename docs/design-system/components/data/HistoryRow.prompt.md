The single row type in History. Newest first, grouped under quiet day headers.

```jsx
<HistoryRow title="Call mom" destination="reminder" when="Tomorrow, 5:00 PM" relative="2h ago" onPress={open} />
```

72px tall, raised surface, hairline divider — `divider={false}` on the last row. Relative time is set in `--font-meta` at 12px so it never competes with the title.
