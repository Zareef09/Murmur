import React from 'react';
import { Icon } from './Icon.jsx';

/**
 * IconButton — quiet circular target for navigation and dismissal. Always at
 * least 44px of hit area even when the glyph is small.
 */
export function IconButton({ name, label, size = 44, tone = 'quiet', onClick, style, ...rest }) {
  const [pressed, setPressed] = React.useState(false);
  const tones = {
    quiet: { background: pressed ? 'var(--bg-sunk)' : 'transparent', color: 'var(--text-secondary)' },
    surface: { background: 'var(--bg-raised)', color: 'var(--text-secondary)', boxShadow: 'var(--shadow-row)' },
    accent: { background: pressed ? 'var(--accent-press)' : 'var(--accent)', color: 'var(--accent-on)' },
  }[tone];
  return (
    <button
      type="button" aria-label={label} onClick={onClick}
      onPointerDown={() => setPressed(true)}
      onPointerUp={() => setPressed(false)}
      onPointerLeave={() => setPressed(false)}
      style={{
        width: size, height: size, display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
        border: 'none', borderRadius: 'var(--radius-pill)', cursor: 'pointer',
        transition: 'background var(--dur-quick) var(--ease-exhale), transform var(--dur-instant) var(--ease-exhale)',
        transform: pressed ? 'scale(.94)' : 'none', WebkitTapHighlightColor: 'transparent',
        ...tones, ...style,
      }}
      {...rest}
    >
      <Icon name={name} size={Math.round(size * 0.45)} />
    </button>
  );
}
