import React from 'react';
import { Icon } from '../core/Icon.jsx';

/**
 * EmptyState — nothing here yet, said warmly. A single hairline ring holds the
 * glyph so the shape rhymes with the capture element.
 */
export function EmptyState({ icon = 'audio-lines', title, body, action, style }) {
  return (
    <div style={{
      display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center',
      gap: 'var(--space-5)', padding: 'var(--space-9) var(--space-7)', ...style,
    }}>
      <span style={{
        width: 76, height: 76, borderRadius: '50%', display: 'grid', placeItems: 'center',
        border: '1px solid var(--line-soft)', color: 'var(--text-tertiary)',
        background: 'var(--accent-glow-faint)',
      }}>
        <Icon name={icon} size={26} />
      </span>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-3)', maxWidth: '28ch' }}>
        <span style={{ font: 'var(--type-headline)', color: 'var(--text-primary)' }}>{title}</span>
        {body ? <span style={{ font: 'var(--type-callout)', color: 'var(--text-secondary)' }}>{body}</span> : null}
      </div>
      {action}
    </div>
  );
}
