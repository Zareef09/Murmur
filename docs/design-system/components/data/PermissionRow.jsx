import React from 'react';
import { Icon } from '../core/Icon.jsx';

/**
 * PermissionRow — states plainly whether Murmur has what it needs. Granted is
 * quiet; needs-attention is warm clay, never alarming red.
 */
export function PermissionRow({ label, status = 'granted', hint, onFix, divider = true, style }) {
  const ok = status === 'granted';
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 'var(--space-4)',
      minHeight: 'var(--hit-comfort)', padding: 'var(--space-4) var(--space-5)',
      borderBottom: divider ? '1px solid var(--line-hairline)' : 'none', ...style,
    }}>
      <span style={{
        width: 26, height: 26, borderRadius: '50%', display: 'grid', placeItems: 'center', flex: '0 0 auto',
        background: ok ? 'var(--success-bg)' : 'var(--attention-bg)',
        color: ok ? 'var(--success-fg)' : 'var(--attention-fg)',
      }}>
        <Icon name={ok ? 'check' : 'circle-alert'} size={14} title={ok ? 'Granted' : 'Needs attention'} />
      </span>
      <span style={{ flex: 1, minWidth: 0, display: 'flex', flexDirection: 'column', gap: 2 }}>
        <span style={{ font: 'var(--type-body)', color: 'var(--text-primary)' }}>{label}</span>
        <span style={{ font: 'var(--type-footnote)', color: ok ? 'var(--text-tertiary)' : 'var(--attention-fg)' }}>
          {hint || (ok ? 'Allowed' : 'Not allowed yet')}
        </span>
      </span>
      {!ok && onFix ? (
        <button type="button" onClick={onFix} style={{
          border: '1px solid var(--line-soft)', background: 'transparent', color: 'var(--text-primary)',
          borderRadius: 'var(--radius-pill)', minHeight: 36, padding: '0 var(--space-5)',
          font: 'var(--type-footnote)', cursor: 'pointer',
        }}>Allow</button>
      ) : null}
    </div>
  );
}
