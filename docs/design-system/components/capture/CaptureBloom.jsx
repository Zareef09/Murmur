import React from 'react';
import { Icon } from '../core/Icon.jsx';

/**
 * CaptureBloom — Murmur's signature interaction: a bead of iridescent glass held
 * inside a guilloché lattice, ringed by a progress arc.
 *
 * Three parts, each doing one job:
 *   glass    wide iridescent gradients turning at incommensurable rates behind a
 *            spherical shade, so the surface reads as light on a film
 *   lattice  a procedural rosette (28 circles on an offset orbit) counter-turning
 *            in two layers — it is the "listening field", brightening with voice
 *   arc      a single ember→violet sweep on the rim: the only progress signal
 *
 *   idle      slow breath, arc resting at a third, lattice dim
 *   listening arc extends with `level`, lattice and glass brighten
 *   thinking  arc detaches into a short travelling sweep
 *   done      arc closes to full, glass blooms, a check fades up
 */
const LATTICE = Array.from({ length: 28 }, (_, i) => {
  const a = (i / 28) * Math.PI * 2;
  return { cx: 50 + 17 * Math.cos(a), cy: 50 + 17 * Math.sin(a) };
});

export function CaptureBloom({ state = 'idle', level = 0, size = 240, onTap, label, style }) {
  const listening = state === 'listening';
  const thinking = state === 'thinking';
  const done = state === 'done';
  const idle = state === 'idle';
  const l = Math.max(0, Math.min(1, level));
  const breath = idle || listening;

  // arc sweep in degrees
  const sweep = done ? 360 : thinking ? 108 : listening ? 120 + l * 210 : 124;
  const uid = React.useId().replace(/[^a-zA-Z0-9]/g, '');
  const R = 48.4, CIRC = 2 * Math.PI * R, dash = (sweep / 360) * CIRC;

  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 'var(--space-6)', ...style }}>
      <button
        type="button" onClick={onTap} aria-label={label || 'Capture a thought'}
        style={{
          position: 'relative', width: size, height: size, border: 'none', background: 'none',
          padding: 0, cursor: 'pointer', WebkitTapHighlightColor: 'transparent', borderRadius: '50%',
        }}
      >
        {/* ambient spill: warm on one side, violet on the other, like the rim light */}
        <div style={{
          position: 'absolute', inset: '-34%', borderRadius: '50%', pointerEvents: 'none',
          background: 'radial-gradient(circle at 32% 62%, var(--accent-glow) 0%, transparent 52%), radial-gradient(circle at 68% 34%, rgba(169,139,255,.30) 0%, transparent 54%)',
          filter: `blur(${Math.round(size * 0.09)}px)`,
          transform: `scale(${listening ? 1 + l * 0.16 : thinking ? 0.9 : done ? 1.1 : 0.96})`,
          opacity: listening ? 0.9 + l * 0.1 : thinking ? 0.62 : done ? 1 : 0.62,
          transition: 'transform var(--dur-slow) var(--ease-exhale), opacity var(--dur-slow) var(--ease-exhale)',
        }} />

        {/* rim arc — ember → violet, round caps, one clean sweep */}
        <div style={{
          position: 'absolute', inset: 0, borderRadius: '50%', pointerEvents: 'none',
          animation: thinking ? 'mm-drift 2400ms linear infinite' : 'none',
        }}>
          <svg viewBox="0 0 100 100" style={{
            position: 'absolute', inset: 0, width: '100%', height: '100%', overflow: 'visible',
            filter: `drop-shadow(0 0 ${Math.round(size * 0.028)}px rgba(168,127,255,.55))`,
          }}>
            <defs>
              <linearGradient id={`arc${uid}`} x1="2%" y1="62%" x2="98%" y2="38%">
                <stop offset="0%" stopColor="var(--iris-arc-from)" />
                <stop offset="46%" stopColor="var(--iris-blush)" />
                <stop offset="100%" stopColor="var(--iris-arc-to)" />
              </linearGradient>
            </defs>
            <circle
              cx="50" cy="50" r={R} fill="none" stroke={`url(#arc${uid})`}
              strokeWidth="1.5" strokeLinecap="round"
              strokeDasharray={`${dash.toFixed(2)} ${(CIRC - dash).toFixed(2)}`}
              transform="rotate(-108 50 50)"
              style={{ transition: 'stroke-dasharray var(--dur-slow) var(--ease-exhale)' }}
            />
          </svg>
        </div>
        {/* faint full track behind the arc, so the ring always closes visually */}
        <div style={{
          position: 'absolute', inset: 0, borderRadius: '50%', pointerEvents: 'none',
          border: '1px solid var(--line-soft)', opacity: 0.7,
        }} />

        {/* the glass body + its lattice */}
        <div style={{
          position: 'absolute', inset: '7%',
          animation: breath ? 'mm-glass-breathe var(--dur-breath) linear infinite' : 'none',
          willChange: 'transform',
        }}>
          {/* guilloché lattice, two counter-turning layers */}
          <svg viewBox="0 0 100 100" style={{
            position: 'absolute', inset: 0, width: '100%', height: '100%', overflow: 'visible',
            opacity: done ? 0.6 : listening ? 0.68 + l * 0.32 : thinking ? 0.55 : 0.6,
            transition: 'opacity var(--dur-normal) var(--ease-exhale)',
            mixBlendMode: 'var(--iris-lattice-blend)',
            filter: `drop-shadow(0 0 ${Math.round(size * 0.012)}px rgba(190,164,255,.6))`,
          }}>
            <g style={{ transformOrigin: '50px 50px', animation: 'mm-drift 74s linear infinite' }}>
              {LATTICE.map((c, i) => (
                <circle key={i} cx={c.cx} cy={c.cy} r="27" fill="none"
                  stroke={i % 2 ? 'var(--iris-blush)' : 'var(--iris-sky)'}
                  strokeWidth="0.3" opacity="0.75" />
              ))}
            </g>
            <g style={{ transformOrigin: '50px 50px', animation: 'mm-drift-back 96s linear infinite' }}>
              {LATTICE.filter((_, i) => i % 2 === 0).map((c, i) => (
                <circle key={i} cx={c.cx} cy={c.cy} r="30" fill="none"
                  stroke="var(--iris-violet)" strokeWidth="0.26" opacity="0.6" />
              ))}
            </g>
          </svg>

          {/* the bead: iridescent film inside a sphere */}
          <div style={{
            position: 'absolute', inset: '17%', borderRadius: '50%', overflow: 'hidden',
            transform: `scale(${done ? 1.1 : thinking ? 0.9 : listening ? 1 + l * 0.07 : 1})`,
            transition: 'transform var(--dur-slow) var(--ease-settle)',
            filter: 'saturate(var(--iris-sat)) contrast(1.04)',
            boxShadow: 'inset 0 0 0 1px rgba(255,255,255,.35), 0 0 26px -6px rgba(190,164,255,.5)',
          }}>
            <div style={{
              position: 'absolute', inset: 0,
              background: 'conic-gradient(from 0deg, var(--iris-blush), var(--iris-peach), var(--iris-mint), var(--iris-sky), var(--iris-violet), var(--iris-blush))',
              filter: `blur(${Math.round(size * 0.045)}px)`,
              animation: 'mm-swirl 26s linear infinite', willChange: 'transform',
            }} />
            <div style={{
              position: 'absolute', inset: 0, mixBlendMode: 'var(--iris-blend)', opacity: 0.85,
              background: 'conic-gradient(from 140deg, transparent, var(--iris-mint) 22%, transparent 42%, var(--iris-blush) 66%, transparent 86%)',
              filter: `blur(${Math.round(size * 0.055)}px)`,
              animation: 'mm-swirl-back 37s linear infinite', willChange: 'transform',
            }} />
            <div style={{
              position: 'absolute', inset: '-10%', mixBlendMode: 'var(--iris-blend)', opacity: 0.7,
              background: 'radial-gradient(circle at 38% 34%, rgba(255,255,255,.6) 0%, transparent 30%), radial-gradient(circle at 68% 72%, var(--iris-violet) 0%, transparent 46%)',
              filter: `blur(${Math.round(size * 0.03)}px)`,
              animation: 'mm-wobble 19s ease-in-out infinite', willChange: 'transform',
            }} />
            {/* spherical shade: light from upper-left, terminator lower-right */}
            <div style={{
              position: 'absolute', inset: 0, borderRadius: '50%', pointerEvents: 'none',
              background: 'radial-gradient(circle at 34% 28%, rgba(255,255,255,.42) 0%, transparent 28%), radial-gradient(circle at 72% 78%, var(--iris-shade) 0%, transparent 52%)',
            }} />
            {/* specular */}
            <div style={{
              position: 'absolute', left: '18%', top: '14%', width: '34%', height: '22%',
              borderRadius: '50%', pointerEvents: 'none',
              background: 'radial-gradient(ellipse at 50% 50%, rgba(255,255,255,.92) 0%, transparent 70%)',
              filter: `blur(${Math.round(size * 0.02)}px)`,
              animation: 'mm-gloss 13s ease-in-out infinite',
            }} />
          </div>

          {/* dim veil when the glass is at rest, so idle stays quiet */}
          <div style={{
            position: 'absolute', inset: 0, borderRadius: '50%', pointerEvents: 'none',
            background: 'var(--bg-base)',
            opacity: done ? 0 : listening ? `calc(var(--iris-veil) * ${(1 - l).toFixed(2)})` : thinking ? 'calc(var(--iris-veil) * 1.25)' : 'var(--iris-veil)',
            transition: 'opacity var(--dur-slow) var(--ease-exhale)',
          }} />
        </div>

        <span style={{
          position: 'absolute', inset: 0, display: 'grid', placeItems: 'center',
          color: 'var(--accent-on-lit)', opacity: done ? 1 : 0,
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
