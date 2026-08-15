import React from 'react';
import { Icon } from '../core/Icon.jsx';

/**
 * CaptureBloom — Murmur's signature interaction: a "light well". A warm bloom of
 * light behind three hairline rings. The rings answer the voice with staggered
 * lag so the response reads as breathing, not as a level meter.
 *
 *   idle      slow 3.8s breath, core dim, one clear tap target
 *   listening bloom opens with `level`; rings follow at 0 / 90 / 180ms lag
 *   thinking  bloom contracts and holds; a single arc drifts around the rim
 *   done      rings settle to rest, core fills, a check fades up
 */
export function CaptureBloom({ state = 'idle', level = 0, size = 240, onTap, label, style }) {
  const listening = state === 'listening';
  const thinking = state === 'thinking';
  const done = state === 'done';
  const l = Math.max(0, Math.min(1, level));

  const ring = (pct, lag, weight) => ({
    position: 'absolute', inset: `${(100 - pct) / 2}%`, borderRadius: '50%',
    border: `${weight}px solid var(--accent)`,
    opacity: done ? 0.16 : listening ? 0.20 + l * 0.34 : thinking ? 0.20 : 0.16,
    transform: `scale(${listening ? 1 + l * 0.10 : thinking ? 0.94 : 1})`,
    transition: `transform var(--dur-slow) var(--ease-exhale) ${lag}ms, opacity var(--dur-normal) var(--ease-exhale) ${lag}ms`,
    animation: state === 'idle' ? `mm-breathe var(--dur-breath) var(--ease-inhale) ${lag * 4}ms infinite` : 'none',
  });

  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 'var(--space-6)', ...style }}>
      <button
        type="button" onClick={onTap} aria-label={label || 'Capture a thought'}
        style={{
          position: 'relative', width: size, height: size, border: 'none', background: 'none',
          padding: 0, cursor: 'pointer', WebkitTapHighlightColor: 'transparent', borderRadius: '50%',
        }}
      >
        {/* the bloom */}
        <div style={{
          position: 'absolute', inset: '-26%', borderRadius: '50%',
          background: 'radial-gradient(circle at 50% 50%, var(--accent-glow) 0%, var(--accent-glow-faint) 42%, transparent 68%)',
          transform: `scale(${listening ? 0.86 + l * 0.42 : thinking ? 0.74 : done ? 0.9 : 0.8})`,
          opacity: listening ? 0.55 + l * 0.45 : thinking ? 0.6 : done ? 0.7 : 0.42,
          transition: 'transform var(--dur-slow) var(--ease-exhale), opacity var(--dur-slow) var(--ease-exhale)',
          filter: 'blur(2px)',
        }} />
        <div style={ring(100, 180, 1)} />
        <div style={ring(76, 90, 1)} />
        <div style={ring(54, 0, 1.5)} />

        {/* drifting arc — the only "thinking" signal */}
        <div style={{
          position: 'absolute', inset: '12%', borderRadius: '50%',
          border: '1.5px solid transparent', borderTopColor: 'var(--accent)',
          opacity: thinking ? 0.85 : 0,
          transition: 'opacity var(--dur-normal) var(--ease-exhale)',
          animation: thinking ? 'mm-drift 2600ms linear infinite' : 'none',
        }} />

        {/* core */}
        <div style={{
          position: 'absolute', inset: '38%', borderRadius: '50%',
          background: 'var(--accent)',
          opacity: done ? 1 : listening ? 0.5 + l * 0.4 : thinking ? 0.4 : 0.26,
          transform: `scale(${done ? 1.14 : listening ? 1 + l * 0.06 : 1})`,
          boxShadow: listening ? 'var(--shadow-listening)' : 'none',
          transition: 'opacity var(--dur-slow) var(--ease-exhale), transform var(--dur-slow) var(--ease-settle), box-shadow var(--dur-slow) var(--ease-exhale)',
        }} />

        <span style={{
          position: 'absolute', inset: 0, display: 'grid', placeItems: 'center',
          color: 'var(--accent-on)', opacity: done ? 1 : 0,
          transition: 'opacity var(--dur-normal) var(--ease-exhale) 120ms',
        }}>
          <Icon name="check" size={Math.round(size * 0.13)} />
        </span>
      </button>
      {label ? (
        <span style={{ font: 'var(--type-subhead)', color: 'var(--text-tertiary)', letterSpacing: '0.02em' }}>{label}</span>
      ) : null}
    </div>
  );
}
