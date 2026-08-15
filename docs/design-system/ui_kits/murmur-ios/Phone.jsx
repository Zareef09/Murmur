const { Icon, IconButton, Wordmark, AppIcon } = window.MurmurDesignSystem_545ca7;

function StatusBar({ time = '9:41' }) {
  return (
    <div style={{ height: 54, display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 30px', position: 'relative', flex: '0 0 auto' }}>
      <span style={{ font: 'var(--weight-semibold) 15px/1 var(--font-core)', color: 'var(--text-primary)', letterSpacing: '-.01em' }}>{time}</span>
      <div style={{ position: 'absolute', left: '50%', top: 10, transform: 'translateX(-50%)', width: 118, height: 34, borderRadius: 99, background: '#000' }} />
      <div style={{ display: 'flex', alignItems: 'flex-end', gap: 5 }}>
        <span style={{ display: 'flex', alignItems: 'flex-end', gap: 2 }}>
          {[5, 7, 9, 11].map((h) => <i key={h} style={{ display: 'block', width: 3, height: h, borderRadius: 1, background: 'var(--text-primary)' }} />)}
        </span>
        <span style={{ width: 25, height: 12, borderRadius: 3.5, border: '1px solid var(--line-strong)', padding: 1.5, display: 'block' }}>
          <i style={{ display: 'block', height: '100%', width: '72%', borderRadius: 2, background: 'var(--text-primary)' }} />
        </span>
      </div>
    </div>
  );
}

function HomeIndicator() {
  return (
    <div style={{ height: 26, display: 'grid', placeItems: 'center', flex: '0 0 auto' }}>
      <span style={{ width: 138, height: 5, borderRadius: 99, background: 'var(--text-primary)', opacity: .28 }} />
    </div>
  );
}

/** Quiet iOS nav bar: back chevron, centred title, optional trailing action. */
function NavBar({ title, onBack, trailing }) {
  return (
    <div style={{ height: 50, display: 'flex', alignItems: 'center', padding: '0 var(--space-4)', gap: 'var(--space-2)', flex: '0 0 auto' }}>
      <span style={{ width: 44 }}>{onBack ? <IconButton name="chevron-left" label="Back" onClick={onBack} /> : null}</span>
      <span style={{ flex: 1, textAlign: 'center', font: 'var(--type-subhead)', color: 'var(--text-primary)' }}>{title}</span>
      <span style={{ width: 44, display: 'flex', justifyContent: 'flex-end' }}>{trailing}</span>
    </div>
  );
}

/** The 393×852 device frame. Content fills it; screens own their own scrolling. */
function Phone({ children, wash }) {
  return (
    <div style={{
      width: 393, height: 852, position: 'relative', flex: '0 0 auto',
      borderRadius: 54, overflow: 'hidden',
      border: '1px solid var(--line-soft)', boxShadow: 'var(--shadow-lift)',
      display: 'flex', flexDirection: 'column',
      background: wash
        ? 'radial-gradient(120% 62% at 50% 14%, var(--accent-glow-faint) 0%, transparent 62%), var(--bg-base)'
        : 'var(--bg-base)',
    }}>{children}</div>
  );
}

/** Grouped-list container used by Settings and History. */
function Group({ title, children, style }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-3)', ...style }}>
      {title ? (
        <span style={{ font: 'var(--type-caption)', textTransform: 'uppercase', letterSpacing: '.08em', color: 'var(--text-tertiary)', padding: '0 var(--space-4)' }}>{title}</span>
      ) : null}
      <div style={{ background: 'var(--bg-raised)', border: '1px solid var(--line-hairline)', borderRadius: 'var(--radius-lg)', overflow: 'hidden', boxShadow: 'var(--shadow-row)' }}>{children}</div>
    </div>
  );
}

Object.assign(window, { Phone, StatusBar, HomeIndicator, NavBar, Group, Icon, IconButton, Wordmark, AppIcon });
