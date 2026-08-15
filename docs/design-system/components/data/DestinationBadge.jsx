import React from 'react';
import { Icon } from '../core/Icon.jsx';

const MAP = {
  reminder: { label: 'Reminder', icon: 'bell', fg: 'var(--reminder-fg)', bg: 'var(--reminder-bg)', line: 'var(--reminder-line)' },
  event: { label: 'Event', icon: 'calendar', fg: 'var(--event-fg)', bg: 'var(--event-bg)', line: 'var(--event-line)' },
};

/**
 * DestinationBadge — tells Reminder and Event apart at a glance. Icon + word +
 * tint, always all three.
 */
export function DestinationBadge({ destination = 'reminder', variant = 'chip', style }) {
  const d = MAP[destination] || MAP.reminder;
  if (variant === 'glyph') {
    return (
      <span title={d.label} style={{
        width: 38, height: 38, borderRadius: 'var(--radius-sm)', display: 'grid', placeItems: 'center',
        background: d.bg, color: d.fg, border: `1px solid ${d.line}`, flex: '0 0 auto', ...style,
      }}>
        <Icon name={d.icon} size={18} title={d.label} />
      </span>
    );
  }
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 'var(--space-2)',
      padding: '5px 10px 5px 8px', borderRadius: 'var(--radius-pill)',
      background: variant === 'quiet' ? 'transparent' : d.bg,
      border: `1px solid ${variant === 'quiet' ? 'transparent' : d.line}`,
      color: d.fg, font: 'var(--type-caption)', letterSpacing: '.03em', ...style,
    }}>
      <Icon name={d.icon} size={13} />{d.label}
    </span>
  );
}
