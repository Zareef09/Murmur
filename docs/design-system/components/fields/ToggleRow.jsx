import React from 'react';

/**
 * ToggleRow — a settings preference. The switch is skinned in ember but the row
 * stays quiet; the label carries the meaning, the description carries the why.
 */
export function ToggleRow({ label, description, checked, onChange, divider = true, style }) {
  return (
    <label style={{
      display: 'flex', alignItems: 'center', gap: 'var(--space-5)',
      minHeight: 'var(--hit-comfort)', padding: 'var(--space-4) var(--space-5)',
      borderBottom: divider ? '1px solid var(--line-hairline)' : 'none',
      cursor: 'pointer', ...style,
    }}>
      <span style={{ flex: 1, minWidth: 0, display: 'flex', flexDirection: 'column', gap: 3 }}>
        <span style={{ font: 'var(--type-body)', color: 'var(--text-primary)' }}>{label}</span>
        {description ? (
          <span style={{ font: 'var(--type-footnote)', color: 'var(--text-tertiary)' }}>{description}</span>
        ) : null}
      </span>
      <span
        role="switch" aria-checked={!!checked}
        onClick={(e) => { e.preventDefault(); onChange && onChange(!checked); }}
        style={{
          position: 'relative', width: 52, height: 32, flex: '0 0 auto',
          borderRadius: 'var(--radius-pill)',
          background: checked ? 'var(--accent)' : 'var(--line-soft)',
          transition: 'background var(--dur-quick) var(--ease-exhale)',
        }}
      >
        <span style={{
          position: 'absolute', top: 3, left: checked ? 23 : 3, width: 26, height: 26,
          borderRadius: '50%', background: 'var(--bg-raised)', boxShadow: 'var(--shadow-row)',
          transition: 'left var(--dur-quick) var(--ease-exhale)',
        }} />
      </span>
    </label>
  );
}
