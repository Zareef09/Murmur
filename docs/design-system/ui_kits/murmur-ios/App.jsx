const P = new URLSearchParams(location.search);

const STATES = [
  ['Onboarding', ['onboarding-1', 'onboarding-2', 'onboarding-3']],
  ['Home Screen', ['springboard']],
  ['Capture', ['capture-first-run', 'capture-idle', 'capture-listening', 'capture-thinking', 'capture-success']],
  ['Confirmation', ['confirm', 'confirm-editing']],
  ['Clarification', ['clarify', 'clarify-answered']],
  ['History', ['history', 'history-empty']],
  ['Settings', ['settings']],
];
const LABELS = {
  'onboarding-1': 'Slide 1 · what it does', 'onboarding-2': 'Slide 2 · permissions', 'onboarding-3': 'Slide 3 · hands-free',
  springboard: 'Icon on the Home Screen',
  'capture-first-run': 'First run', 'capture-idle': 'Idle', 'capture-listening': 'Listening',
  'capture-thinking': 'Processing', 'capture-success': 'Success + Undo',
  confirm: 'Confident case', 'confirm-editing': 'Correcting a field',
  clarify: 'Listening for the answer', 'clarify-answered': 'Answer received',
  history: 'Populated', 'history-empty': 'Empty',
  settings: 'Settings',
};

function App() {
  const [screen, setScreen] = React.useState(P.get('screen') || 'capture-idle');
  const [editing, setEditing] = React.useState(P.get('screen') === 'confirm-editing' ? 'when' : null);
  const [dest, setDest] = React.useState('reminder');
  const [dark, setDark] = React.useState(P.get('theme') === 'dark');
  const chrome = P.get('chrome') !== '0';

  React.useEffect(() => { document.documentElement.dataset.theme = dark ? 'dark' : 'light'; }, [dark]);

  // idle → listening → thinking → confirmation, on the app's own clock
  React.useEffect(() => {
    if (!chrome) return;
    if (screen === 'capture-listening') { const t = setTimeout(() => setScreen('capture-thinking'), 4600); return () => clearTimeout(t); }
    if (screen === 'capture-thinking') { const t = setTimeout(() => setScreen('confirm'), 1500); return () => clearTimeout(t); }
    if (screen === 'capture-success') { const t = setTimeout(() => setScreen('capture-idle'), 5000); return () => clearTimeout(t); }
  }, [screen, chrome]);

  const go = (s) => { setScreen(s); setEditing(s === 'confirm-editing' ? 'when' : null); };

  const captureState = screen.startsWith('capture-') ? screen.slice(8) : 'idle';
  const onConfirm = screen.startsWith('confirm');

  let body;
  if (screen.startsWith('onboarding')) {
    const i = Number(screen.slice(-1)) - 1;
    body = <OnboardingScreen index={i} onNext={() => go(i < 2 ? `onboarding-${i + 2}` : 'capture-first-run')} onSkip={() => go('capture-first-run')} />;
  } else if (screen === 'springboard') {
    body = <SpringboardScreen onOpen={() => go('capture-idle')} />;
  } else if (screen.startsWith('clarify')) {
    body = <ClarifyScreen answered={screen === 'clarify-answered'} onBack={() => go('capture-idle')} />;
  } else if (screen.startsWith('history')) {
    body = <HistoryScreen empty={screen === 'history-empty'} onBack={() => go('capture-idle')} />;
  } else if (screen === 'settings') {
    body = <SettingsScreen onBack={() => go('capture-idle')} />;
  } else {
    body = (
      <React.Fragment>
        <CaptureScreen
          state={onConfirm ? 'thinking' : captureState}
          onTap={() => go(captureState === 'listening' ? 'capture-thinking' : 'capture-listening')}
          onHistory={() => go('history')}
          onSettings={() => go('settings')}
        />
        {onConfirm ? (
          <ConfirmSheet
            editing={editing} destination={dest}
            onEdit={(f) => setEditing((e) => (e === f ? null : f))}
            onDestination={setDest}
            onSave={() => go('capture-success')}
            onCancel={() => go('capture-idle')}
          />
        ) : null}
      </React.Fragment>
    );
  }

  const phone = <Phone wash={screen.startsWith('capture') || onConfirm || screen.startsWith('clarify') || screen.startsWith('onboarding')}>{body}</Phone>;
  if (!chrome) return phone;

  return (
    <div style={{ display: 'flex', gap: 44, alignItems: 'flex-start' }}>
      <aside style={{ width: 246, display: 'flex', flexDirection: 'column', gap: 'var(--space-6)', paddingTop: 8 }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <Wordmark size={22} />
          <button type="button" onClick={() => setDark((d) => !d)} style={{
            display: 'inline-flex', alignItems: 'center', gap: 8, border: '1px solid var(--line-soft)',
            background: 'var(--bg-raised)', color: 'var(--text-secondary)', borderRadius: 99,
            padding: '7px 13px', font: 'var(--type-footnote)', cursor: 'pointer',
          }}>
            <Icon name={dark ? 'sun' : 'moon'} size={14} />{dark ? 'Light' : 'Dark'}
          </button>
        </div>
        {STATES.map(([group, items]) => (
          <div key={group} style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            <span style={{ font: 'var(--type-caption)', textTransform: 'uppercase', letterSpacing: '.08em', color: 'var(--text-tertiary)' }}>{group}</span>
            {items.map((s) => {
              const on = s === screen;
              return (
                <button key={s} type="button" onClick={() => go(s)} style={{
                  textAlign: 'left', border: '1px solid', borderColor: on ? 'var(--accent)' : 'transparent',
                  background: on ? 'var(--accent-quiet)' : 'transparent',
                  color: on ? 'var(--text-accent)' : 'var(--text-secondary)',
                  borderRadius: 'var(--radius-sm)', padding: '9px 12px', font: 'var(--type-footnote)', cursor: 'pointer',
                }}>{LABELS[s]}</button>
              );
            })}
          </div>
        ))}
        <a href="gallery.html" style={{ font: 'var(--type-footnote)' }}>Every screen, both modes →</a>
      </aside>
      {phone}
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
