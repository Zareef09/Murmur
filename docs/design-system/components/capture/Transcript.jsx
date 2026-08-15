import React from 'react';

/**
 * Transcript — the words as they arrive. Settled words sit at full contrast,
 * the in-flight tail sits back a step, so the sentence appears to firm up.
 */
export function Transcript({ text = '', partial = '', placeholder, align = 'center', style }) {
  const empty = !text && !partial;
  return (
    <p style={{
      margin: 0, font: 'var(--type-transcript)', letterSpacing: 'var(--ls-transcript)',
      textAlign: align, textWrap: 'pretty', maxWidth: '30ch',
      color: empty ? 'var(--text-tertiary)' : 'var(--text-primary)',
      transition: 'color var(--dur-normal) var(--ease-exhale)',
      ...style,
    }}>
      {empty ? placeholder : text}
      {partial ? (
        <span style={{
          color: 'var(--text-tertiary)',
          animation: 'mm-rise var(--dur-normal) var(--ease-exhale)',
        }}>{text ? ' ' : ''}{partial}</span>
      ) : null}
    </p>
  );
}
