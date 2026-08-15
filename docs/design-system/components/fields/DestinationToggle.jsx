import React from 'react';
import { Icon } from '../core/Icon.jsx';

const OPTIONS = [
  { id: 'reminder', label: 'Reminder', icon: 'bell', fg: 'var(--reminder-fg)', bg: 'var(--reminder-bg)' },
  { id: 'event', label: 'Event', icon: 'calendar', fg: 'var(--event-fg)', bg: 'var(--event-bg)' },
];

/**
 * DestinationToggle — where the thought lands. Two options only, each carrying
 * icon + word + its own tint, so it never depends on color alone.
 */
export function DestinationToggle({ value = 'reminder', onChange, size = 'md', style }) {
  return (
    <div role="radiogroup" style={{
      display: 'flex', gap: 'var(--space-2)', padding: 'var(--space-1)',
      background: 'var(--bg-sunk)', borderRadius: 'var(--radius-pill)', ...style,
    }}>
      {OPTIONS.map((o) => {
        const on = value === o.id;
        return (
          <button
            key={o.id} type="button" role="radio" aria-checked={on}
            onClick={() => onChange && onChange(o.id)}
            style={{
              flex: 1, display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
              gap: 'var(--space-3)', minHeight: size === 'sm' ? 38 : 46, padding: '0 var(--space-5)',
              border: `1px solid ${on ? o.fg : 'transparent'}`, borderRadius: 'var(--radius-pill)',
              background: on ? o.bg : 'transparent',
              color: on ? o.fg : 'var(--text-secondary)',
              font: on ? 'var(--type-subhead)' : 'var(--weight-regular) var(--size-subhead)/1.38 var(--font-core)',
              cursor: 'pointer', WebkitTapHighlightColor: 'transparent',
              transition: 'background var(--dur-quick) var(--ease-exhale), color var(--dur-quick) var(--ease-exhale), border-color var(--dur-quick) var(--ease-exhale)',
            }}
          >
            <Icon name={o.icon} size={16} />{o.label}
          </button>
        );
      })}
    </div>
  );
}
