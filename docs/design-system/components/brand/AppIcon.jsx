import React from 'react';

/**
 * AppIcon — the light well, reduced to its smallest legible form: a warm ground,
 * two hairline rings and an ember core. No microphone.
 */
export function AppIcon({ size = 120, theme = 'light', style }) {
  const dark = theme === 'dark';
  const ring = (pct, alpha, weight) => ({
    position: 'absolute', inset: `${(100 - pct) / 2}%`, borderRadius: '50%',
    border: `${weight}px solid ${dark ? `rgba(239,190,139,${alpha})` : `rgba(152,72,29,${alpha})`}`,
  });
  return (
    <div style={{
      position: 'relative', width: size, height: size, borderRadius: 'var(--radius-icon)',
      overflow: 'hidden', flex: '0 0 auto',
      background: dark
        ? 'radial-gradient(120% 120% at 50% 34%, #34291D 0%, #17130E 68%)'
        : 'radial-gradient(120% 120% at 50% 34%, #FDF3E4 0%, #F0E2CD 70%)',
      boxShadow: 'var(--shadow-card)', ...style,
    }}>
      <div style={ring(78, dark ? .30 : .22, Math.max(1, size * 0.008))} />
      <div style={ring(54, dark ? .42 : .3, Math.max(1, size * 0.008))} />
      <div style={{
        position: 'absolute', inset: '38%', borderRadius: '50%',
        background: dark ? 'var(--ember-400)' : 'var(--ember-600)',
        boxShadow: `0 0 ${size * 0.22}px ${dark ? 'rgba(239,190,139,.5)' : 'rgba(210,128,58,.42)'}`,
      }} />
    </div>
  );
}
