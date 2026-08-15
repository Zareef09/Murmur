import React from 'react';

const BASE = () => (typeof window !== 'undefined' && window.MURMUR_ICON_BASE) || 'assets/icons';

/**
 * Icon — a monochrome glyph rendered as a CSS mask so it always takes
 * currentColor. Wraps the Lucide set shipped in assets/icons/ (a stand-in for
 * SF Symbols, which cannot be redistributed — see readme ICONOGRAPHY).
 */
export function Icon({ name, size = 20, strokeScale = 1, style, title, ...rest }) {
  const url = `${BASE()}/${name}.svg`;
  return (
    <span
      role={title ? 'img' : 'presentation'}
      aria-label={title}
      aria-hidden={title ? undefined : true}
      style={{
        display: 'inline-block', width: size, height: size, flex: '0 0 auto',
        background: 'currentColor',
        WebkitMaskImage: `url("${url}")`, maskImage: `url("${url}")`,
        WebkitMaskRepeat: 'no-repeat', maskRepeat: 'no-repeat',
        WebkitMaskPosition: 'center', maskPosition: 'center',
        WebkitMaskSize: `${100 * strokeScale}% ${100 * strokeScale}%`,
        maskSize: `${100 * strokeScale}% ${100 * strokeScale}%`,
        ...style,
      }}
      {...rest}
    />
  );
}
