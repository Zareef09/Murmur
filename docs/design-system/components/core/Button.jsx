import React from 'react';
import { Icon } from './Icon.jsx';

const pad = { sm: '0 16px', md: '0 22px', lg: '0 28px' };
const height = { sm: 40, md: 52, lg: 60 };

/**
 * Button — one primary action per screen. Ember fill for primary, hairline for
 * secondary, bare text for ghost. Presses settle rather than bounce.
 */
export function Button({
  variant = 'primary', size = 'lg', icon, iconAfter, fullWidth,
  disabled, children, onClick, style, ...rest
}) {
  const [pressed, setPressed] = React.useState(false);
  const base = {
    display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
    gap: 'var(--space-3)', minHeight: height[size], padding: pad[size],
    width: fullWidth ? '100%' : undefined,
    font: size === 'sm' ? 'var(--type-subhead)' : 'var(--type-body-em)',
    borderRadius: 'var(--radius-pill)', border: '1px solid transparent',
    cursor: disabled ? 'default' : 'pointer', textAlign: 'center',
    transition: 'background var(--dur-quick) var(--ease-exhale), color var(--dur-quick) var(--ease-exhale), border-color var(--dur-quick) var(--ease-exhale), transform var(--dur-instant) var(--ease-exhale), opacity var(--dur-quick) linear',
    transform: pressed && !disabled ? 'scale(.982)' : 'none',
    opacity: disabled ? .38 : 1,
    WebkitTapHighlightColor: 'transparent',
  };
  const skin = {
    primary: { background: pressed ? 'var(--accent-press)' : 'var(--accent)', color: 'var(--accent-on)' },
    secondary: { background: 'transparent', color: 'var(--text-primary)', borderColor: pressed ? 'var(--line-strong)' : 'var(--line-soft)' },
    ghost: { background: pressed ? 'var(--accent-quiet)' : 'transparent', color: 'var(--text-accent)', padding: size === 'sm' ? '0 10px' : '0 14px' },
  }[variant];
  return (
    <button
      type="button" disabled={disabled} onClick={disabled ? undefined : onClick}
      onPointerDown={() => setPressed(true)}
      onPointerUp={() => setPressed(false)}
      onPointerLeave={() => setPressed(false)}
      style={{ ...base, ...skin, ...style }}
      {...rest}
    >
      {icon ? <Icon name={icon} size={size === 'sm' ? 16 : 19} /> : null}
      <span>{children}</span>
      {iconAfter ? <Icon name={iconAfter} size={size === 'sm' ? 16 : 19} /> : null}
    </button>
  );
}
