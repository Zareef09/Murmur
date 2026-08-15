import React from 'react';
import { Icon } from '../core/Icon.jsx';
import { DestinationBadge } from './DestinationBadge.jsx';

/**
 * HistoryRow — one past capture. Title leads, destination and date sit under it,
 * relative time trails. Swipe reveals a single delete action.
 */
export function HistoryRow({
  title, destination = 'reminder', when, relative, swiped, divider = true,
  onPress, onSwipe, onDelete, style,
}) {
  return (
    <div style={{ position: 'relative', overflow: 'hidden', ...style }}>
      <button type="button" onClick={onDelete} aria-label="Delete" style={{
        position: 'absolute', inset: '0 0 0 auto', width: 92, border: 'none',
        background: 'var(--attention-bg)', color: 'var(--attention-fg)',
        display: 'grid', placeItems: 'center', cursor: 'pointer',
      }}>
        <Icon name="trash-2" size={19} />
      </button>
      <div
        onClick={swiped ? onSwipe : onPress}
        style={{
          position: 'relative', display: 'flex', alignItems: 'center', gap: 'var(--space-4)',
          minHeight: 72, padding: 'var(--space-4) var(--space-5)',
          background: 'var(--bg-raised)', cursor: 'pointer',
          borderBottom: divider ? '1px solid var(--line-hairline)' : 'none',
          transform: swiped ? 'translateX(-92px)' : 'none',
          transition: 'transform var(--dur-normal) var(--ease-exhale)',
        }}
      >
        <DestinationBadge destination={destination} variant="glyph" />
        <div style={{ flex: 1, minWidth: 0, display: 'flex', flexDirection: 'column', gap: 3 }}>
          <span style={{ font: 'var(--type-body)', color: 'var(--text-primary)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{title}</span>
          <span style={{ font: 'var(--type-footnote)', color: 'var(--text-secondary)' }}>
            {destination === 'event' ? 'Event' : 'Reminder'}{when ? ` · ${when}` : ''}
          </span>
        </div>
        {relative ? (
          <span style={{ font: 'var(--type-meta)', fontSize: 12, color: 'var(--text-tertiary)', flex: '0 0 auto' }}>{relative}</span>
        ) : null}
        <Icon name="chevron-right" size={16} style={{ color: 'var(--text-tertiary)', opacity: .6 }} />
      </div>
    </div>
  );
}
