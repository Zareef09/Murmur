import React from 'react';

/**
 * AppIconM — the app logo: a single letter M, drawn as one continuous
 * monoline stroke with soft rounded joints, echoing Hanken Grotesk's soft
 * terminals. Flat ground, one hairline, one soft shadow — the M is the
 * whole mark; nothing else competes with it.
 */
export function AppIconM({ size = 120, theme = 'dark', style }) {
  const dark = theme === 'dark';
  const bg = dark ? 'var(--sand-1000)' : 'var(--sand-50)';
  const ink = dark ? '#F2EBDF' : 'var(--sand-900)';
  const hairlineRgb = dark ? '242,235,223' : '33,29,24';
  return (
    <div style={{
      position: 'relative', width: size, height: size, borderRadius: 'var(--radius-icon)',
      flex: '0 0 auto', background: bg,
      border: `1px solid rgba(${hairlineRgb},.09)`,
      boxShadow: 'var(--shadow-card)', ...style,
    }}>
      <svg viewBox="0 0 100 100" width="100%" height="100%">
        <polyline points="23,76 23,24 50,58 77,24 77,76" fill="none" stroke={ink}
          strokeWidth="10.5" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    </div>
  );
}
