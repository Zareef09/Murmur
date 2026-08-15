const { HistoryRow, EmptyState, Button, ToggleRow, PermissionRow, DestinationToggle } = window.MurmurDesignSystem_545ca7;

const ITEMS = [
  { title: 'Call mom', destination: 'reminder', when: 'Tomorrow, 5:00 PM', relative: '2h ago', day: 'Today' },
  { title: 'Coffee with Ana', destination: 'event', when: 'Fri, 9:30 AM', relative: '5h ago', day: 'Today' },
  { title: 'Buy cat food', destination: 'reminder', relative: '9h ago', day: 'Today' },
  { title: 'Dentist', destination: 'event', when: 'Mon 25, 8:00 AM', relative: 'Yesterday', day: 'Yesterday' },
  { title: 'Move the car before street cleaning', destination: 'reminder', when: 'Wed, 7:00 AM', relative: 'Yesterday', day: 'Yesterday' },
];

function HistoryScreen({ empty, onBack }) {
  const [swiped, setSwiped] = React.useState(null);
  const days = ['Today', 'Yesterday'];
  return (
    <React.Fragment>
      <StatusBar />
      <NavBar title="History" onBack={onBack} />
      {empty ? (
        <div style={{ flex: 1, display: 'grid', placeItems: 'center' }}>
          <EmptyState icon="list" title="Nothing captured yet" body="Tap the well on the home screen and say the thing you keep almost forgetting." action={<Button variant="secondary" size="md" onClick={onBack}>Capture something</Button>} />
        </div>
      ) : (
        <div style={{ flex: 1, overflowY: 'auto', padding: '0 var(--gutter-screen) var(--space-8)', display: 'flex', flexDirection: 'column', gap: 'var(--space-7)' }}>
          {days.map((day) => (
            <Group key={day} title={day}>
              {ITEMS.filter((i) => i.day === day).map((i, idx, arr) => (
                <HistoryRow key={i.title} {...i} divider={idx < arr.length - 1}
                  swiped={swiped === i.title}
                  onPress={() => setSwiped(i.title)}
                  onSwipe={() => setSwiped(null)}
                  onDelete={() => setSwiped(null)} />
              ))}
            </Group>
          ))}
          <span style={{ font: 'var(--type-footnote)', color: 'var(--text-tertiary)', textAlign: 'center' }}>Tap a row to swipe it aside, then delete.</span>
        </div>
      )}
      <HomeIndicator />
    </React.Fragment>
  );
}

function SettingsScreen({ onBack }) {
  const [confirm, setConfirm] = React.useState(true);
  const [speak, setSpeak] = React.useState(true);
  const [dest, setDest] = React.useState('reminder');
  return (
    <React.Fragment>
      <StatusBar />
      <NavBar title="Settings" onBack={onBack} />
      <div style={{ flex: 1, overflowY: 'auto', padding: '0 var(--gutter-screen) var(--space-8)', display: 'flex', flexDirection: 'column', gap: 'var(--space-7)' }}>
        <Group title="Capture">
          <ToggleRow label="Always confirm before saving" description="Glance at what Murmur heard before it files it." checked={confirm} onChange={setConfirm} />
          <ToggleRow label="Speak questions aloud" description="When something's unclear, Murmur asks out loud." checked={speak} onChange={setSpeak} divider={false} />
        </Group>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-3)' }}>
          <span style={{ font: 'var(--type-caption)', textTransform: 'uppercase', letterSpacing: '.08em', color: 'var(--text-tertiary)', padding: '0 var(--space-4)' }}>Default destination</span>
          <DestinationToggle value={dest} onChange={setDest} />
          <span style={{ font: 'var(--type-footnote)', color: 'var(--text-tertiary)', padding: '0 var(--space-4)' }}>Used when what you say has no obvious time attached.</span>
        </div>

        <Group title="Permissions">
          <PermissionRow label="Microphone" status="granted" />
          <PermissionRow label="Reminders" status="granted" />
          <PermissionRow label="Calendar" status="needed" hint="Needed to save events" onFix={() => {}} divider={false} />
        </Group>

        <Group title="Hands-free">
          <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-4)', minHeight: 'var(--hit-comfort)', padding: 'var(--space-4) var(--space-5)', cursor: 'pointer' }}>
            <Icon name="mic" size={19} style={{ color: 'var(--text-tertiary)' }} />
            <span style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 2 }}>
              <span style={{ font: 'var(--type-body)' }}>Set up Action Button launch</span>
              <span style={{ font: 'var(--type-footnote)', color: 'var(--text-tertiary)' }}>Three steps, about a minute</span>
            </span>
            <Icon name="chevron-right" size={16} style={{ color: 'var(--text-tertiary)' }} />
          </div>
        </Group>
        <span style={{ font: 'var(--type-meta)', fontSize: 11, color: 'var(--text-tertiary)', textAlign: 'center' }}>murmur 1.0 (12)</span>
      </div>
      <HomeIndicator />
    </React.Fragment>
  );
}

Object.assign(window, { HistoryScreen, SettingsScreen });
