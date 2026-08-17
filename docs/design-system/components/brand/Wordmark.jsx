import React from 'react';

/**
 * Wordmark — the single letter "M" set in the core face at 300, always
 * lowercase-weighted. The ember dot beside it is the captured thought: the
 * mark is a sentence let out and safely kept.
 */
export function Wordmark({ size = 28, tone = 'primary', dot = true, style }) {
  const color = tone === 'inverse' ? 'var(--text-inverse)' : tone === 'accent' ? 'var(--text-accent)' : 'var(--text-primary)';
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'baseline', gap: size * 0.16,
      font: `var(--weight-light) ${size}px/1 var(--font-core)`,
      letterSpacing: 'var(--ls-wordmark)', color, ...style,
    }}>
      M
      {dot ? (
        <span style={{
          width: Math.max(4, size * 0.145), height: Math.max(4, size * 0.145),
          borderRadius: '50%', background: 'var(--accent)', flex: '0 0 auto',
          marginLeft: -size * 0.05,
        }} />
      ) : null}
    </span>
  );
}
