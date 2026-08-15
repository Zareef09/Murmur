const { EditableField, DestinationToggle, Button, CaptureBloom } = window.MurmurDesignSystem_545ca7;

/** Skin over the system DatePicker — behaviour stays native, only the paint changes. */
function DateWheel() {
  const cols = [['Today', 'Tomorrow', 'Fri 22 Aug'], ['4', '5', '6'], ['00', '15', '30'], ['AM', 'PM']];
  return (
    <div style={{ position: 'relative', display: 'flex', gap: 'var(--space-5)', height: 116, marginTop: 'var(--space-2)', justifyContent: 'center' }}>
      <div style={{ position: 'absolute', left: 0, right: 0, top: 40, height: 36, borderRadius: 'var(--radius-sm)', background: 'var(--accent-quiet)' }} />
      {cols.map((c, i) => (
        <div key={i} style={{ display: 'flex', flexDirection: 'column', gap: 8, alignItems: 'center', paddingTop: 8 }}>
          {c.map((v, j) => (
            <span key={v} style={{
              font: j === 1 ? 'var(--type-body-em)' : 'var(--type-body)',
              color: j === 1 ? 'var(--text-primary)' : 'var(--text-tertiary)',
              opacity: j === 1 ? 1 : .7, height: 28, display: 'flex', alignItems: 'center',
            }}>{v}</span>
          ))}
        </div>
      ))}
    </div>
  );
}

function ConfirmSheet({ editing = null, destination = 'reminder', onEdit, onSave, onCancel, onDestination }) {
  const [title, setTitle] = React.useState('Call mom');
  return (
    <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', justifyContent: 'flex-end' }}>
      <div style={{ position: 'absolute', inset: 0, background: 'var(--bg-overlay)' }} onClick={onCancel} />
      <div style={{
        position: 'relative', background: 'var(--bg-base)', borderRadius: 'var(--radius-xl) var(--radius-xl) 0 0',
        boxShadow: 'var(--shadow-sheet)', padding: 'var(--space-5) var(--gutter-sheet) var(--space-5)',
        display: 'flex', flexDirection: 'column', gap: 'var(--space-5)',
        animation: 'mm-rise var(--dur-normal) var(--ease-exhale)',
      }}>
        <span style={{ width: 40, height: 4, borderRadius: 99, background: 'var(--line-soft)', alignSelf: 'center' }} />
        <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-4)' }}>
          <CaptureBloom state="done" size={44} />
          <div style={{ display: 'flex', flexDirection: 'column' }}>
            <span style={{ font: 'var(--type-headline)' }}>{editing ? 'Fix it up' : 'Does this look right?'}</span>
            <span style={{ font: 'var(--type-footnote)', color: 'var(--text-tertiary)' }}>Tap anything to change it.</span>
          </div>
        </div>

        <div style={{ background: 'var(--bg-raised)', border: '1px solid var(--line-hairline)', borderRadius: 'var(--radius-lg)', padding: 6, display: 'flex', flexDirection: 'column' }}>
          <EditableField label="Title" value={title} onChange={setTitle} editing={editing === 'title'} onPress={() => onEdit('title')} />
          <div style={{ height: 1, background: 'var(--line-hairline)', margin: '0 var(--space-5)' }} />
          <EditableField label="When" icon="clock" value="Tomorrow, 5:00 PM" editing={editing === 'when'} onPress={() => onEdit('when')}>
            <DateWheel />
          </EditableField>
          <div style={{ height: 1, background: 'var(--line-hairline)', margin: '0 var(--space-5)' }} />
          <EditableField label="Goes to" icon={destination === 'event' ? 'calendar' : 'bell'} value={destination === 'event' ? 'Calendar · Personal' : 'Reminders · Inbox'} editing={editing === 'dest'} onPress={() => onEdit('dest')}>
            <DestinationToggle value={destination} onChange={onDestination} size="sm" style={{ marginTop: 6 }} />
          </EditableField>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-3)' }}>
          <Button variant="primary" fullWidth onClick={onSave}>{destination === 'event' ? 'Save event' : 'Save reminder'}</Button>
          <Button variant="ghost" size="md" fullWidth onClick={onCancel}>Cancel</Button>
        </div>
        <HomeIndicator />
      </div>
    </div>
  );
}

Object.assign(window, { ConfirmSheet, DateWheel });
