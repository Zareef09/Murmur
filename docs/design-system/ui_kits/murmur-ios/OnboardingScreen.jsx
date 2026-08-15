const { Button, CaptureBloom, PermissionRow, Wordmark: WM, AppIcon: AI } = window.MurmurDesignSystem_545ca7;

const SLIDES = [
  {
    kind: 'intro',
    title: 'Say it once. It\u2019s kept.',
    body: 'Speak a thought the way you\u2019d say it to a person. Murmur files it as a reminder or an event.',
    cta: 'Next',
  },
  {
    kind: 'permissions',
    title: 'Two things to allow',
    body: 'Your microphone, so Murmur can hear you. Reminders and Calendar, so it has somewhere to put things. Nothing leaves your phone unasked.',
    cta: 'Allow access',
  },
  {
    kind: 'handsfree',
    title: 'One press, hands free',
    body: 'Put Murmur on the Action Button and capture without looking. You can set this up later in Settings.',
    cta: 'Set it up',
  },
];

function OnboardingScreen({ index = 0, onNext, onSkip }) {
  const s = SLIDES[index];
  return (
    <React.Fragment>
      <StatusBar />
      <div style={{ display: 'flex', justifyContent: 'flex-end', padding: '0 var(--space-4)' }}>
        <Button variant="ghost" size="sm" onClick={onSkip}>Skip</Button>
      </div>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', gap: 'var(--space-9)', padding: '0 var(--gutter-screen)' }}>
        <div style={{ display: 'grid', placeItems: 'center', minHeight: 220 }}>
          {s.kind === 'intro' ? <CaptureBloom state="idle" size={196} />
            : s.kind === 'permissions' ? (
              <div style={{ width: '100%', background: 'var(--bg-raised)', border: '1px solid var(--line-hairline)', borderRadius: 'var(--radius-lg)', overflow: 'hidden' }}>
                <PermissionRow label="Microphone" status="needed" hint="So Murmur can hear you" />
                <PermissionRow label="Reminders" status="needed" hint="Somewhere to keep tasks" />
                <PermissionRow label="Calendar" status="needed" hint="Somewhere to keep events" divider={false} />
              </div>
            ) : <AI size={132} />}
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-4)' }}>
          <h1 style={{ margin: 0, font: 'var(--type-display)', letterSpacing: 'var(--ls-display)', maxWidth: '16ch' }}>{s.title}</h1>
          <p style={{ margin: 0, font: 'var(--type-callout)', color: 'var(--text-secondary)', maxWidth: '30ch' }}>{s.body}</p>
        </div>
      </div>
      <div style={{ padding: '0 var(--gutter-screen) var(--space-5)', display: 'flex', flexDirection: 'column', gap: 'var(--space-5)' }}>
        <div style={{ display: 'flex', gap: 6, justifyContent: 'center' }}>
          {SLIDES.map((_, i) => (
            <span key={i} style={{ width: i === index ? 20 : 6, height: 6, borderRadius: 99, background: i === index ? 'var(--accent)' : 'var(--line-soft)', transition: 'width var(--dur-normal) var(--ease-exhale)' }} />
          ))}
        </div>
        <Button variant="primary" fullWidth onClick={onNext}>{s.cta}</Button>
      </div>
      <HomeIndicator />
    </React.Fragment>
  );
}

/** iOS Home Screen — the icon in its real habitat, light and dark. */
function SpringboardScreen({ onOpen }) {
  const apps = ['Calendar', 'Notes', 'Weather', 'Photos', 'Clock', 'Maps'];
  return (
    <React.Fragment>
      <StatusBar />
      <div style={{ flex: 1, padding: 'var(--space-8) var(--space-7)', display: 'flex', flexDirection: 'column', gap: 'var(--space-8)' }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 'var(--space-7) var(--space-5)' }}>
          <button type="button" onClick={onOpen} style={{ border: 'none', background: 'none', padding: 0, cursor: 'pointer', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 7 }}>
            <AI size={66} />
            <span style={{ font: 'var(--weight-regular) 11px/1.2 var(--font-core)', color: 'var(--text-primary)' }}>murmur</span>
          </button>
          {apps.map((a) => (
            <span key={a} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 7 }}>
              <span style={{ width: 66, height: 66, borderRadius: 'var(--radius-icon)', background: 'var(--bg-sunk)', border: '1px solid var(--line-hairline)' }} />
              <span style={{ font: 'var(--weight-regular) 11px/1.2 var(--font-core)', color: 'var(--text-tertiary)' }}>{a}</span>
            </span>
          ))}
        </div>
        <div style={{ marginTop: 'auto', display: 'flex', justifyContent: 'center' }}>
          <span style={{ font: 'var(--type-footnote)', color: 'var(--text-tertiary)' }}>Home Screen · icon at 66px</span>
        </div>
      </div>
      <HomeIndicator />
    </React.Fragment>
  );
}

Object.assign(window, { OnboardingScreen, SpringboardScreen, SLIDES });
