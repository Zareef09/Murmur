Every field on the Confirmation sheet is one of these — the whole row is the tap target.

```jsx
<EditableField label="When" icon="clock" value="Tomorrow, 5:00 PM" onPress={editDate} />
<EditableField label="When" icon="clock" value="Tomorrow, 5:00 PM" editing>
  <DatePickerSkin />
</EditableField>
```

Missing values read as a calm statement, not an error: `placeholder="No date"`. Only one field is `editing` at a time.
