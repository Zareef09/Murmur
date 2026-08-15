import React from 'react';
import { Icon } from '../core/Icon.jsx';

/**
 * EditableField — a parsed value the user can glance at and fix. Resting state is
 * plain text with a quiet pencil; editing lifts the field onto a raised surface
 * with an ember hairline. Rows are 60px so they clear the 44px minimum with air.
 */
export function EditableField({
  label, value, placeholder = 'Not set', icon, editing, muted,
  onPress, onChange, children, style,
}) {
  const shown = value || placeholder;
  return (
    <div
      onClick={editing ? undefined : onPress}
      style={{
        display: 'flex', alignItems: 'center', gap: 'var(--space-4)',
        minHeight: 60, padding: '10px var(--space-5)',
        background: editing ? 'var(--bg-raised)' : 'transparent',
        border: `1px solid ${editing ? 'var(--accent)' : 'transparent'}`,
        borderRadius: 'var(--radius-md)',
        cursor: editing ? 'default' : 'pointer',
        transition: 'background var(--dur-normal) var(--ease-exhale), border-color var(--dur-normal) var(--ease-exhale)',
        ...style,
      }}
    >
      {icon ? <Icon name={icon} size={19} style={{ color: 'var(--text-tertiary)' }} /> : null}
      <div style={{ flex: 1, minWidth: 0, display: 'flex', flexDirection: 'column', gap: 2 }}>
        {label ? (
          <span style={{ font: 'var(--type-caption)', color: 'var(--text-tertiary)', textTransform: 'uppercase', letterSpacing: '.08em' }}>{label}</span>
        ) : null}
        {editing && children ? children : editing ? (
          <input
            autoFocus value={value || ''} onChange={(e) => onChange && onChange(e.target.value)}
            style={{
              font: 'var(--type-body)', color: 'var(--text-primary)', background: 'none',
              border: 'none', outline: 'none', padding: 0, width: '100%',
            }}
          />
        ) : (
          <span style={{
            font: 'var(--type-body)',
            color: value ? (muted ? 'var(--text-secondary)' : 'var(--text-primary)') : 'var(--text-tertiary)',
            overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
          }}>{shown}</span>
        )}
      </div>
      {!editing ? <Icon name="pencil" size={16} style={{ color: 'var(--text-tertiary)', opacity: .65 }} /> : null}
    </div>
  );
}
