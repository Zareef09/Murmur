const { CaptureBloom, Transcript, Button, DestinationToggle } = window.MurmurDesignSystem_545ca7;

/** Clarification — Murmur asked out loud and is listening for the answer. */
function ClarifyScreen({ onBack, answered }) {
  const level = useLevel(!answered);
  return (
    <React.Fragment>
      <StatusBar />
      <NavBar onBack={onBack} title="" />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', padding: '0 var(--gutter-screen)', gap: 'var(--space-8)' }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-4)' }}>
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 8, font: 'var(--type-caption)', textTransform: 'uppercase', letterSpacing: '.08em', color: 'var(--text-tertiary)' }}>
            <Icon name="volume-2" size={14} />Murmur asked
          </span>
          <p style={{ margin: 0, font: 'var(--type-title)', letterSpacing: 'var(--ls-title)', maxWidth: '20ch' }}>
            Which day did you mean — Friday or Saturday?
          </p>
        </div>

        <div style={{ display: 'flex', alignItems: 'flex-start', gap: 'var(--space-5)' }}>
          <CaptureBloom state={answered ? 'thinking' : 'listening'} level={level} size={64} />
          <Transcript
            align="left"
            text={answered ? 'Friday, the early one' : 'Friday'}
            partial={answered ? '' : ', the early…'}
            placeholder="I'm listening…"
            style={{ fontSize: 22, maxWidth: '18ch' }}
          />
        </div>

        <div style={{ marginTop: 'auto', display: 'flex', flexDirection: 'column', gap: 'var(--space-4)', paddingBottom: 'var(--space-6)' }}>
          <span style={{ font: 'var(--type-footnote)', color: 'var(--text-tertiary)' }}>Somewhere quiet? Tap an answer instead.</span>
          <div style={{ display: 'flex', gap: 'var(--space-3)' }}>
            <Button variant="secondary" size="md" fullWidth>Friday</Button>
            <Button variant="secondary" size="md" fullWidth>Saturday</Button>
          </div>
          <Button variant="ghost" size="md" fullWidth onClick={onBack}>Start over</Button>
        </div>
      </div>
      <HomeIndicator />
    </React.Fragment>
  );
}

Object.assign(window, { ClarifyScreen });
