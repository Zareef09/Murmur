const { CaptureBloom, Transcript, SuccessBar, Button } = window.MurmurDesignSystem_545ca7;

/** Simulated, smoothed mic amplitude — the real app feeds this from the audio tap. */
function useLevel(active) {
  const [level, setLevel] = React.useState(0);
  React.useEffect(() => {
    if (!active) { setLevel(0); return; }
    let t = 0;
    const id = setInterval(() => {
      t += 0.08;
      const raw = 0.5 + 0.42 * Math.sin(t) * Math.sin(t * 0.41) + 0.06 * Math.sin(t * 4.3);
      setLevel((p) => p + (Math.max(0, Math.min(1, raw)) - p) * 0.3);
    }, 60);
    return () => clearInterval(id);
  }, [active]);
  return level;
}

const SPOKEN = ['Remind me', 'Remind me to call mom', 'Remind me to call mom tomorrow', 'Remind me to call mom tomorrow at five'];

function CaptureScreen({ state = 'idle', onTap, onHistory, onSettings }) {
  const level = useLevel(state === 'listening');
  const [step, setStep] = React.useState(0);
  React.useEffect(() => {
    if (state !== 'listening') { setStep(0); return; }
    const id = setInterval(() => setStep((s) => (s + 1) % (SPOKEN.length + 1)), 1400);
    return () => clearInterval(id);
  }, [state]);

  const firstRun = state === 'first-run';
  const bloomState = state === 'first-run' ? 'idle' : state === 'success' ? 'done' : state;
  const label = { idle: 'Tap to speak', 'first-run': 'Tap, then just say it', listening: 'Listening', thinking: 'One moment', success: 'Saved' }[state];
  const spoken = SPOKEN[Math.max(0, Math.min(SPOKEN.length - 1, step - 1))];

  return (
    <React.Fragment>
      <StatusBar />
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 var(--space-4)', flex: '0 0 auto' }}>
        <IconButton name="list" label="History" onClick={onHistory} />
        <Wordmark size={19} dot={false} style={{ color: 'var(--text-tertiary)', letterSpacing: '.16em' }} />
        <IconButton name="settings" label="Settings" onClick={onSettings} />
      </div>

      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 'var(--space-9)', padding: '0 var(--gutter-screen) var(--space-10)' }}>
        {firstRun ? (
          <p style={{ margin: 0, font: 'var(--type-title)', letterSpacing: 'var(--ls-title)', textAlign: 'center', maxWidth: '18ch', color: 'var(--text-primary)' }}>
            Say what you need to remember.
          </p>
        ) : (
          <div style={{ minHeight: 108, display: 'flex', alignItems: 'flex-end' }}>
            {state === 'listening' ? (
              <Transcript text={step > 1 ? SPOKEN[step - 2] : ''} partial={step > 0 ? spoken.replace(step > 1 ? SPOKEN[step - 2] : '', '').trim() : ''} placeholder="I'm listening…" />
            ) : state === 'thinking' ? (
              <Transcript text="Remind me to call mom tomorrow at five" style={{ color: 'var(--text-secondary)' }} />
            ) : state === 'success' ? (
              <Transcript text="Call mom" style={{ fontSize: 22 }} />
            ) : null}
          </div>
        )}

        <CaptureBloom state={bloomState} level={level} size={244} onTap={onTap} label={label} />

        {firstRun ? (
          <p style={{ margin: 0, font: 'var(--type-footnote)', color: 'var(--text-tertiary)', textAlign: 'center', maxWidth: '26ch' }}>
            Murmur files it as a reminder or an event. You can always check before it saves.
          </p>
        ) : <div style={{ height: 18 }} />}
      </div>

      <div style={{ padding: '0 var(--gutter-screen)', minHeight: 76, flex: '0 0 auto' }}>
        {state === 'success' ? (
          <SuccessBar message="Saved to Reminders · tomorrow 5:00 PM" destination="reminder" onUndo={() => {}} />
        ) : null}
      </div>
      <HomeIndicator />
    </React.Fragment>
  );
}

Object.assign(window, { CaptureScreen, useLevel });
