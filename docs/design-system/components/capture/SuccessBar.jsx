import React from 'react';
import { Icon } from '../core/Icon.jsx';

/**
 * SuccessBar — the soft exhale. States what was saved and where, and keeps Undo
 * within reach for --undo-window before it fades out on its own.
 */
export function SuccessBar({ message = 'Saved', destination = 'reminder', onUndo, style }) {
  const isEvent = destination === 'event';
  return (
    <div
      role="status"
      style={{
        display: 'flex', alignItems: 'center', gap: 'var(--space-4)',
        padding: '14px var(--space-5) 14px var(--space-5)',
        background: 'var(--bg-raised)', border: '1px solid var(--line-hairline)',
        borderRadius: 'var(--radius-pill)', boxShadow: 'var(--shadow-card)',
        animation: 'mm-rise var(--dur-normal) var(--ease-settle)',
        ...style,
      }}
    >
      <span style={{
        width: 28, height: 28, borderRadius: '50%', display: 'grid', placeItems: 'center',
        background: isEvent ? 'var(--event-bg)' : 'var(--reminder-bg)',
        color: isEvent ? 'var(--event-fg)' : 'var(--reminder-fg)', flex: '0 0 auto',
      }}>
        <Icon name={isEvent ? 'calendar' : 'bell'} size={15} />
      </span>
      <span style={{ font: 'var(--type-subhead)', color: 'var(--text-primary)', flex: 1, minWidth: 0 }}>{message}</span>
      {onUndo ? (
        <button type="button" onClick={onUndo} style={{
          border: 'none', background: 'none', padding: '6px 4px', cursor: 'pointer',
          display: 'inline-flex', alignItems: 'center', gap: 6,
          color: 'var(--text-accent)', font: 'var(--type-subhead)',
        }}>
          <Icon name="undo-2" size={15} />Undo
        </button>
      ) : null}
    </div>
  );
}
