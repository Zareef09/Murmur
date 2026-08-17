/* @ds-bundle: {"format":4,"namespace":"MurmurDesignSystem_545ca7","components":[{"name":"AppIcon","sourcePath":"components/brand/AppIcon.jsx"},{"name":"AppIconM","sourcePath":"components/brand/AppIconM.jsx"},{"name":"Wordmark","sourcePath":"components/brand/Wordmark.jsx"},{"name":"CaptureBloom","sourcePath":"components/capture/CaptureBloom.jsx"},{"name":"SuccessBar","sourcePath":"components/capture/SuccessBar.jsx"},{"name":"Transcript","sourcePath":"components/capture/Transcript.jsx"},{"name":"Button","sourcePath":"components/core/Button.jsx"},{"name":"Icon","sourcePath":"components/core/Icon.jsx"},{"name":"IconButton","sourcePath":"components/core/IconButton.jsx"},{"name":"DestinationBadge","sourcePath":"components/data/DestinationBadge.jsx"},{"name":"EmptyState","sourcePath":"components/data/EmptyState.jsx"},{"name":"HistoryRow","sourcePath":"components/data/HistoryRow.jsx"},{"name":"PermissionRow","sourcePath":"components/data/PermissionRow.jsx"},{"name":"DestinationToggle","sourcePath":"components/fields/DestinationToggle.jsx"},{"name":"EditableField","sourcePath":"components/fields/EditableField.jsx"},{"name":"ToggleRow","sourcePath":"components/fields/ToggleRow.jsx"}],"sourceHashes":{"components/brand/AppIcon.jsx":"130528f76cce","components/brand/AppIconM.jsx":"5a72b14ac1ad","components/brand/Wordmark.jsx":"579ecd1af394","components/capture/CaptureBloom.jsx":"5f7718381c95","components/capture/SuccessBar.jsx":"f3bf5c1129a8","components/capture/Transcript.jsx":"f1a0eff3a484","components/core/Button.jsx":"b986543220f1","components/core/Icon.jsx":"b8b6178547c4","components/core/IconButton.jsx":"e808a5e8055d","components/data/DestinationBadge.jsx":"e30926f7532e","components/data/EmptyState.jsx":"89b9f6fa6a3c","components/data/HistoryRow.jsx":"0213a9f7cef6","components/data/PermissionRow.jsx":"81e2f30e5a77","components/fields/DestinationToggle.jsx":"6ba4b9e0d075","components/fields/EditableField.jsx":"b5056d97f169","components/fields/ToggleRow.jsx":"e71ed9cd4e5c","ui_kits/murmur-ios/App.jsx":"2827cde8343e","ui_kits/murmur-ios/CaptureScreen.jsx":"7e906769a97a","ui_kits/murmur-ios/ClarifyScreen.jsx":"e485f617ae92","ui_kits/murmur-ios/ConfirmSheet.jsx":"8c9e0e9038ea","ui_kits/murmur-ios/ListScreens.jsx":"651260fc1d7f","ui_kits/murmur-ios/OnboardingScreen.jsx":"5a29a09c2c1d","ui_kits/murmur-ios/Phone.jsx":"2d4e7f459964"},"inlinedExternals":[],"unexposedExports":[]} */

(() => {

const __ds_ns = (window.MurmurDesignSystem_545ca7 = window.MurmurDesignSystem_545ca7 || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// components/brand/AppIcon.jsx
try { (() => {
/**
 * AppIcon — the light well, reduced to its smallest legible form: a warm ground,
 * two hairline rings and an ember core. No microphone.
 */
function AppIcon({
  size = 120,
  theme = 'light',
  style
}) {
  const dark = theme === 'dark';
  const ring = (pct, alpha, weight) => ({
    position: 'absolute',
    inset: `${(100 - pct) / 2}%`,
    borderRadius: '50%',
    border: `${weight}px solid ${dark ? `rgba(239,190,139,${alpha})` : `rgba(152,72,29,${alpha})`}`
  });
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      width: size,
      height: size,
      borderRadius: 'var(--radius-icon)',
      overflow: 'hidden',
      flex: '0 0 auto',
      background: dark ? 'radial-gradient(120% 120% at 50% 34%, #34291D 0%, #17130E 68%)' : 'radial-gradient(120% 120% at 50% 34%, #FDF3E4 0%, #F0E2CD 70%)',
      boxShadow: 'var(--shadow-card)',
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: ring(78, dark ? .30 : .22, Math.max(1, size * 0.008))
  }), /*#__PURE__*/React.createElement("div", {
    style: ring(54, dark ? .42 : .3, Math.max(1, size * 0.008))
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: '38%',
      borderRadius: '50%',
      background: dark ? 'var(--ember-400)' : 'var(--ember-600)',
      boxShadow: `0 0 ${size * 0.22}px ${dark ? 'rgba(239,190,139,.5)' : 'rgba(210,128,58,.42)'}`
    }
  }));
}
Object.assign(__ds_scope, { AppIcon });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/brand/AppIcon.jsx", error: String((e && e.message) || e) }); }

// components/brand/AppIconM.jsx
try { (() => {
/**
 * AppIconM — the app logo: a single letter M, drawn as one continuous
 * monoline stroke with soft rounded joints, echoing Hanken Grotesk's soft
 * terminals. Flat ground, one hairline, one soft shadow — the M is the
 * whole mark; nothing else competes with it.
 */
function AppIconM({
  size = 120,
  theme = 'dark',
  style
}) {
  const dark = theme === 'dark';
  const bg = dark ? 'var(--sand-1000)' : 'var(--sand-50)';
  const ink = dark ? '#F2EBDF' : 'var(--sand-900)';
  const hairlineRgb = dark ? '242,235,223' : '33,29,24';
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      width: size,
      height: size,
      borderRadius: 'var(--radius-icon)',
      flex: '0 0 auto',
      background: bg,
      border: `1px solid rgba(${hairlineRgb},.09)`,
      boxShadow: 'var(--shadow-card)',
      ...style
    }
  }, /*#__PURE__*/React.createElement("svg", {
    viewBox: "0 0 100 100",
    width: "100%",
    height: "100%"
  }, /*#__PURE__*/React.createElement("polyline", {
    points: "23,76 23,24 50,58 77,24 77,76",
    fill: "none",
    stroke: ink,
    strokeWidth: "10.5",
    strokeLinecap: "round",
    strokeLinejoin: "round"
  })));
}
Object.assign(__ds_scope, { AppIconM });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/brand/AppIconM.jsx", error: String((e && e.message) || e) }); }

// components/brand/Wordmark.jsx
try { (() => {
/**
 * Wordmark — the single letter "M" set in the core face at 300, always
 * lowercase-weighted. The ember dot beside it is the captured thought: the
 * mark is a sentence let out and safely kept.
 */
function Wordmark({
  size = 28,
  tone = 'primary',
  dot = true,
  style
}) {
  const color = tone === 'inverse' ? 'var(--text-inverse)' : tone === 'accent' ? 'var(--text-accent)' : 'var(--text-primary)';
  return /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'baseline',
      gap: size * 0.16,
      font: `var(--weight-light) ${size}px/1 var(--font-core)`,
      letterSpacing: 'var(--ls-wordmark)',
      color,
      ...style
    }
  }, "M", dot ? /*#__PURE__*/React.createElement("span", {
    style: {
      width: Math.max(4, size * 0.145),
      height: Math.max(4, size * 0.145),
      borderRadius: '50%',
      background: 'var(--accent)',
      flex: '0 0 auto',
      marginLeft: -size * 0.05
    }
  }) : null);
}
Object.assign(__ds_scope, { Wordmark });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/brand/Wordmark.jsx", error: String((e && e.message) || e) }); }

// components/capture/Transcript.jsx
try { (() => {
/**
 * Transcript — the words as they arrive. Settled words sit at full contrast,
 * the in-flight tail sits back a step, so the sentence appears to firm up.
 */
function Transcript({
  text = '',
  partial = '',
  placeholder,
  align = 'center',
  style
}) {
  const empty = !text && !partial;
  return /*#__PURE__*/React.createElement("p", {
    style: {
      margin: 0,
      font: 'var(--type-transcript)',
      letterSpacing: 'var(--ls-transcript)',
      textAlign: align,
      textWrap: 'pretty',
      maxWidth: '30ch',
      color: empty ? 'var(--text-tertiary)' : 'var(--text-primary)',
      transition: 'color var(--dur-normal) var(--ease-exhale)',
      ...style
    }
  }, empty ? placeholder : text, partial ? /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--text-tertiary)',
      animation: 'mm-rise var(--dur-normal) var(--ease-exhale)'
    }
  }, text ? ' ' : '', partial) : null);
}
Object.assign(__ds_scope, { Transcript });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/capture/Transcript.jsx", error: String((e && e.message) || e) }); }

// components/core/Icon.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const BASE = () => typeof window !== 'undefined' && window.MURMUR_ICON_BASE || 'assets/icons';

/**
 * Icon — a monochrome glyph rendered as a CSS mask so it always takes
 * currentColor. Wraps the Lucide set shipped in assets/icons/ (a stand-in for
 * SF Symbols, which cannot be redistributed — see readme ICONOGRAPHY).
 */
function Icon({
  name,
  size = 20,
  strokeScale = 1,
  style,
  title,
  ...rest
}) {
  const url = `${BASE()}/${name}.svg`;
  return /*#__PURE__*/React.createElement("span", _extends({
    role: title ? 'img' : 'presentation',
    "aria-label": title,
    "aria-hidden": title ? undefined : true,
    style: {
      display: 'inline-block',
      width: size,
      height: size,
      flex: '0 0 auto',
      background: 'currentColor',
      WebkitMaskImage: `url("${url}")`,
      maskImage: `url("${url}")`,
      WebkitMaskRepeat: 'no-repeat',
      maskRepeat: 'no-repeat',
      WebkitMaskPosition: 'center',
      maskPosition: 'center',
      WebkitMaskSize: `${100 * strokeScale}% ${100 * strokeScale}%`,
      maskSize: `${100 * strokeScale}% ${100 * strokeScale}%`,
      ...style
    }
  }, rest));
}
Object.assign(__ds_scope, { Icon });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Icon.jsx", error: String((e && e.message) || e) }); }

// components/capture/CaptureBloom.jsx
try { (() => {
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
const LATTICE = Array.from({
  length: 28
}, (_, i) => {
  const a = i / 28 * Math.PI * 2;
  return {
    cx: 50 + 17 * Math.cos(a),
    cy: 50 + 17 * Math.sin(a)
  };
});
function CaptureBloom({
  state = 'idle',
  level = 0,
  size = 240,
  onTap,
  label,
  style
}) {
  const listening = state === 'listening';
  const thinking = state === 'thinking';
  const done = state === 'done';
  const idle = state === 'idle';
  const l = Math.max(0, Math.min(1, level));
  const breath = idle || listening;

  // arc sweep in degrees
  const sweep = done ? 360 : thinking ? 108 : listening ? 120 + l * 210 : 124;
  const uid = React.useId().replace(/[^a-zA-Z0-9]/g, '');
  const R = 48.4,
    CIRC = 2 * Math.PI * R,
    dash = sweep / 360 * CIRC;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      gap: 'var(--space-6)',
      ...style
    }
  }, /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onTap,
    "aria-label": label || 'Capture a thought',
    style: {
      position: 'relative',
      width: size,
      height: size,
      border: 'none',
      background: 'none',
      padding: 0,
      cursor: 'pointer',
      WebkitTapHighlightColor: 'transparent',
      borderRadius: '50%'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: '-34%',
      borderRadius: '50%',
      pointerEvents: 'none',
      background: 'radial-gradient(circle at 32% 62%, var(--accent-glow) 0%, transparent 52%), radial-gradient(circle at 68% 34%, rgba(169,139,255,.30) 0%, transparent 54%)',
      filter: `blur(${Math.round(size * 0.09)}px)`,
      transform: `scale(${listening ? 1 + l * 0.16 : thinking ? 0.9 : done ? 1.1 : 0.96})`,
      opacity: listening ? 0.9 + l * 0.1 : thinking ? 0.62 : done ? 1 : 0.62,
      transition: 'transform var(--dur-slow) var(--ease-exhale), opacity var(--dur-slow) var(--ease-exhale)'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      borderRadius: '50%',
      pointerEvents: 'none',
      animation: thinking ? 'mm-drift 2400ms linear infinite' : 'none'
    }
  }, /*#__PURE__*/React.createElement("svg", {
    viewBox: "0 0 100 100",
    style: {
      position: 'absolute',
      inset: 0,
      width: '100%',
      height: '100%',
      overflow: 'visible',
      filter: `drop-shadow(0 0 ${Math.round(size * 0.028)}px rgba(168,127,255,.55))`
    }
  }, /*#__PURE__*/React.createElement("defs", null, /*#__PURE__*/React.createElement("linearGradient", {
    id: `arc${uid}`,
    x1: "2%",
    y1: "62%",
    x2: "98%",
    y2: "38%"
  }, /*#__PURE__*/React.createElement("stop", {
    offset: "0%",
    stopColor: "var(--iris-arc-from)"
  }), /*#__PURE__*/React.createElement("stop", {
    offset: "46%",
    stopColor: "var(--iris-blush)"
  }), /*#__PURE__*/React.createElement("stop", {
    offset: "100%",
    stopColor: "var(--iris-arc-to)"
  }))), /*#__PURE__*/React.createElement("circle", {
    cx: "50",
    cy: "50",
    r: R,
    fill: "none",
    stroke: `url(#arc${uid})`,
    strokeWidth: "1.5",
    strokeLinecap: "round",
    strokeDasharray: `${dash.toFixed(2)} ${(CIRC - dash).toFixed(2)}`,
    transform: "rotate(-108 50 50)",
    style: {
      transition: 'stroke-dasharray var(--dur-slow) var(--ease-exhale)'
    }
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      borderRadius: '50%',
      pointerEvents: 'none',
      border: '1px solid var(--line-soft)',
      opacity: 0.7
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: '7%',
      animation: breath ? 'mm-glass-breathe var(--dur-breath) linear infinite' : 'none',
      willChange: 'transform'
    }
  }, /*#__PURE__*/React.createElement("svg", {
    viewBox: "0 0 100 100",
    style: {
      position: 'absolute',
      inset: 0,
      width: '100%',
      height: '100%',
      overflow: 'visible',
      opacity: done ? 0.6 : listening ? 0.68 + l * 0.32 : thinking ? 0.55 : 0.6,
      transition: 'opacity var(--dur-normal) var(--ease-exhale)',
      mixBlendMode: 'var(--iris-lattice-blend)',
      filter: `drop-shadow(0 0 ${Math.round(size * 0.012)}px rgba(190,164,255,.6))`
    }
  }, /*#__PURE__*/React.createElement("g", {
    style: {
      transformOrigin: '50px 50px',
      animation: 'mm-drift 74s linear infinite'
    }
  }, LATTICE.map((c, i) => /*#__PURE__*/React.createElement("circle", {
    key: i,
    cx: c.cx,
    cy: c.cy,
    r: "27",
    fill: "none",
    stroke: i % 2 ? 'var(--iris-blush)' : 'var(--iris-sky)',
    strokeWidth: "0.3",
    opacity: "0.75"
  }))), /*#__PURE__*/React.createElement("g", {
    style: {
      transformOrigin: '50px 50px',
      animation: 'mm-drift-back 96s linear infinite'
    }
  }, LATTICE.filter((_, i) => i % 2 === 0).map((c, i) => /*#__PURE__*/React.createElement("circle", {
    key: i,
    cx: c.cx,
    cy: c.cy,
    r: "30",
    fill: "none",
    stroke: "var(--iris-violet)",
    strokeWidth: "0.26",
    opacity: "0.6"
  })))), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: '17%',
      borderRadius: '50%',
      overflow: 'hidden',
      transform: `scale(${done ? 1.1 : thinking ? 0.9 : listening ? 1 + l * 0.07 : 1})`,
      transition: 'transform var(--dur-slow) var(--ease-settle)',
      filter: 'saturate(var(--iris-sat)) contrast(1.04)',
      boxShadow: 'inset 0 0 0 1px rgba(255,255,255,.35), 0 0 26px -6px rgba(190,164,255,.5)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      background: 'conic-gradient(from 0deg, var(--iris-blush), var(--iris-peach), var(--iris-mint), var(--iris-sky), var(--iris-violet), var(--iris-blush))',
      filter: `blur(${Math.round(size * 0.045)}px)`,
      animation: 'mm-swirl 26s linear infinite',
      willChange: 'transform'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      mixBlendMode: 'var(--iris-blend)',
      opacity: 0.85,
      background: 'conic-gradient(from 140deg, transparent, var(--iris-mint) 22%, transparent 42%, var(--iris-blush) 66%, transparent 86%)',
      filter: `blur(${Math.round(size * 0.055)}px)`,
      animation: 'mm-swirl-back 37s linear infinite',
      willChange: 'transform'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: '-10%',
      mixBlendMode: 'var(--iris-blend)',
      opacity: 0.7,
      background: 'radial-gradient(circle at 38% 34%, rgba(255,255,255,.6) 0%, transparent 30%), radial-gradient(circle at 68% 72%, var(--iris-violet) 0%, transparent 46%)',
      filter: `blur(${Math.round(size * 0.03)}px)`,
      animation: 'mm-wobble 19s ease-in-out infinite',
      willChange: 'transform'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      borderRadius: '50%',
      pointerEvents: 'none',
      background: 'radial-gradient(circle at 34% 28%, rgba(255,255,255,.42) 0%, transparent 28%), radial-gradient(circle at 72% 78%, var(--iris-shade) 0%, transparent 52%)'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      left: '18%',
      top: '14%',
      width: '34%',
      height: '22%',
      borderRadius: '50%',
      pointerEvents: 'none',
      background: 'radial-gradient(ellipse at 50% 50%, rgba(255,255,255,.92) 0%, transparent 70%)',
      filter: `blur(${Math.round(size * 0.02)}px)`,
      animation: 'mm-gloss 13s ease-in-out infinite'
    }
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      borderRadius: '50%',
      pointerEvents: 'none',
      background: 'var(--bg-base)',
      opacity: done ? 0 : listening ? `calc(var(--iris-veil) * ${(1 - l).toFixed(2)})` : thinking ? 'calc(var(--iris-veil) * 1.25)' : 'var(--iris-veil)',
      transition: 'opacity var(--dur-slow) var(--ease-exhale)'
    }
  })), /*#__PURE__*/React.createElement("span", {
    style: {
      position: 'absolute',
      inset: 0,
      display: 'grid',
      placeItems: 'center',
      color: 'var(--accent-on-lit)',
      opacity: done ? 1 : 0,
      transition: 'opacity var(--dur-normal) var(--ease-exhale) 120ms'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "check",
    size: Math.round(size * 0.13)
  }))), label ? /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-subhead)',
      color: 'var(--text-tertiary)',
      letterSpacing: '0.02em'
    }
  }, label) : null);
}
Object.assign(__ds_scope, { CaptureBloom });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/capture/CaptureBloom.jsx", error: String((e && e.message) || e) }); }

// components/capture/SuccessBar.jsx
try { (() => {
/**
 * SuccessBar — the soft exhale. States what was saved and where, and keeps Undo
 * within reach for --undo-window before it fades out on its own.
 */
function SuccessBar({
  message = 'Saved',
  destination = 'reminder',
  onUndo,
  style
}) {
  const isEvent = destination === 'event';
  return /*#__PURE__*/React.createElement("div", {
    role: "status",
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 'var(--space-4)',
      padding: '14px var(--space-5) 14px var(--space-5)',
      background: 'var(--bg-raised)',
      border: '1px solid var(--line-hairline)',
      borderRadius: 'var(--radius-pill)',
      boxShadow: 'var(--shadow-card)',
      animation: 'mm-rise var(--dur-normal) var(--ease-settle)',
      ...style
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 28,
      height: 28,
      borderRadius: '50%',
      display: 'grid',
      placeItems: 'center',
      background: isEvent ? 'var(--event-bg)' : 'var(--reminder-bg)',
      color: isEvent ? 'var(--event-fg)' : 'var(--reminder-fg)',
      flex: '0 0 auto'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: isEvent ? 'calendar' : 'bell',
    size: 15
  })), /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-subhead)',
      color: 'var(--text-primary)',
      flex: 1,
      minWidth: 0
    }
  }, message), onUndo ? /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onUndo,
    style: {
      border: 'none',
      background: 'none',
      padding: '6px 4px',
      cursor: 'pointer',
      display: 'inline-flex',
      alignItems: 'center',
      gap: 6,
      color: 'var(--text-accent)',
      font: 'var(--type-subhead)'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "undo-2",
    size: 15
  }), "Undo") : null);
}
Object.assign(__ds_scope, { SuccessBar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/capture/SuccessBar.jsx", error: String((e && e.message) || e) }); }

// components/core/Button.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const pad = {
  sm: '0 16px',
  md: '0 22px',
  lg: '0 28px'
};
const height = {
  sm: 40,
  md: 52,
  lg: 60
};

/**
 * Button — one primary action per screen. Ember fill for primary, hairline for
 * secondary, bare text for ghost. Presses settle rather than bounce.
 */
function Button({
  variant = 'primary',
  size = 'lg',
  icon,
  iconAfter,
  fullWidth,
  disabled,
  children,
  onClick,
  style,
  ...rest
}) {
  const [pressed, setPressed] = React.useState(false);
  const base = {
    display: 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 'var(--space-3)',
    minHeight: height[size],
    padding: pad[size],
    width: fullWidth ? '100%' : undefined,
    font: size === 'sm' ? 'var(--type-subhead)' : 'var(--type-body-em)',
    borderRadius: 'var(--radius-pill)',
    border: '1px solid transparent',
    cursor: disabled ? 'default' : 'pointer',
    textAlign: 'center',
    transition: 'background var(--dur-quick) var(--ease-exhale), color var(--dur-quick) var(--ease-exhale), border-color var(--dur-quick) var(--ease-exhale), transform var(--dur-instant) var(--ease-exhale), opacity var(--dur-quick) linear',
    transform: pressed && !disabled ? 'scale(.982)' : 'none',
    opacity: disabled ? .38 : 1,
    WebkitTapHighlightColor: 'transparent'
  };
  const skin = {
    primary: {
      background: pressed ? 'var(--accent-press)' : 'var(--accent)',
      color: 'var(--accent-on)'
    },
    secondary: {
      background: 'transparent',
      color: 'var(--text-primary)',
      borderColor: pressed ? 'var(--line-strong)' : 'var(--line-soft)'
    },
    ghost: {
      background: pressed ? 'var(--accent-quiet)' : 'transparent',
      color: 'var(--text-accent)',
      padding: size === 'sm' ? '0 10px' : '0 14px'
    }
  }[variant];
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    disabled: disabled,
    onClick: disabled ? undefined : onClick,
    onPointerDown: () => setPressed(true),
    onPointerUp: () => setPressed(false),
    onPointerLeave: () => setPressed(false),
    style: {
      ...base,
      ...skin,
      ...style
    }
  }, rest), icon ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: size === 'sm' ? 16 : 19
  }) : null, /*#__PURE__*/React.createElement("span", null, children), iconAfter ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: iconAfter,
    size: size === 'sm' ? 16 : 19
  }) : null);
}
Object.assign(__ds_scope, { Button });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Button.jsx", error: String((e && e.message) || e) }); }

// components/core/IconButton.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * IconButton — quiet circular target for navigation and dismissal. Always at
 * least 44px of hit area even when the glyph is small.
 */
function IconButton({
  name,
  label,
  size = 44,
  tone = 'quiet',
  onClick,
  style,
  ...rest
}) {
  const [pressed, setPressed] = React.useState(false);
  const tones = {
    quiet: {
      background: pressed ? 'var(--bg-sunk)' : 'transparent',
      color: 'var(--text-secondary)'
    },
    surface: {
      background: 'var(--bg-raised)',
      color: 'var(--text-secondary)',
      boxShadow: 'var(--shadow-row)'
    },
    accent: {
      background: pressed ? 'var(--accent-press)' : 'var(--accent)',
      color: 'var(--accent-on)'
    }
  }[tone];
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    "aria-label": label,
    onClick: onClick,
    onPointerDown: () => setPressed(true),
    onPointerUp: () => setPressed(false),
    onPointerLeave: () => setPressed(false),
    style: {
      width: size,
      height: size,
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      border: 'none',
      borderRadius: 'var(--radius-pill)',
      cursor: 'pointer',
      transition: 'background var(--dur-quick) var(--ease-exhale), transform var(--dur-instant) var(--ease-exhale)',
      transform: pressed ? 'scale(.94)' : 'none',
      WebkitTapHighlightColor: 'transparent',
      ...tones,
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: name,
    size: Math.round(size * 0.45)
  }));
}
Object.assign(__ds_scope, { IconButton });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/IconButton.jsx", error: String((e && e.message) || e) }); }

// components/data/DestinationBadge.jsx
try { (() => {
const MAP = {
  reminder: {
    label: 'Reminder',
    icon: 'bell',
    fg: 'var(--reminder-fg)',
    bg: 'var(--reminder-bg)',
    line: 'var(--reminder-line)'
  },
  event: {
    label: 'Event',
    icon: 'calendar',
    fg: 'var(--event-fg)',
    bg: 'var(--event-bg)',
    line: 'var(--event-line)'
  }
};

/**
 * DestinationBadge — tells Reminder and Event apart at a glance. Icon + word +
 * tint, always all three.
 */
function DestinationBadge({
  destination = 'reminder',
  variant = 'chip',
  style
}) {
  const d = MAP[destination] || MAP.reminder;
  if (variant === 'glyph') {
    return /*#__PURE__*/React.createElement("span", {
      title: d.label,
      style: {
        width: 38,
        height: 38,
        borderRadius: 'var(--radius-sm)',
        display: 'grid',
        placeItems: 'center',
        background: d.bg,
        color: d.fg,
        border: `1px solid ${d.line}`,
        flex: '0 0 auto',
        ...style
      }
    }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: d.icon,
      size: 18,
      title: d.label
    }));
  }
  return /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 'var(--space-2)',
      padding: '5px 10px 5px 8px',
      borderRadius: 'var(--radius-pill)',
      background: variant === 'quiet' ? 'transparent' : d.bg,
      border: `1px solid ${variant === 'quiet' ? 'transparent' : d.line}`,
      color: d.fg,
      font: 'var(--type-caption)',
      letterSpacing: '.03em',
      ...style
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: d.icon,
    size: 13
  }), d.label);
}
Object.assign(__ds_scope, { DestinationBadge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data/DestinationBadge.jsx", error: String((e && e.message) || e) }); }

// components/data/EmptyState.jsx
try { (() => {
/**
 * EmptyState — nothing here yet, said warmly. A single hairline ring holds the
 * glyph so the shape rhymes with the capture element.
 */
function EmptyState({
  icon = 'audio-lines',
  title,
  body,
  action,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      textAlign: 'center',
      gap: 'var(--space-5)',
      padding: 'var(--space-9) var(--space-7)',
      ...style
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 76,
      height: 76,
      borderRadius: '50%',
      display: 'grid',
      placeItems: 'center',
      border: '1px solid var(--line-soft)',
      color: 'var(--text-tertiary)',
      background: 'var(--accent-glow-faint)'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 26
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--space-3)',
      maxWidth: '28ch'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-headline)',
      color: 'var(--text-primary)'
    }
  }, title), body ? /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-callout)',
      color: 'var(--text-secondary)'
    }
  }, body) : null), action);
}
Object.assign(__ds_scope, { EmptyState });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data/EmptyState.jsx", error: String((e && e.message) || e) }); }

// components/data/HistoryRow.jsx
try { (() => {
/**
 * HistoryRow — one past capture. Title leads, destination and date sit under it,
 * relative time trails. Swipe reveals a single delete action.
 */
function HistoryRow({
  title,
  destination = 'reminder',
  when,
  relative,
  swiped,
  divider = true,
  onPress,
  onSwipe,
  onDelete,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      overflow: 'hidden',
      ...style
    }
  }, /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onDelete,
    "aria-label": "Delete",
    style: {
      position: 'absolute',
      inset: '0 0 0 auto',
      width: 92,
      border: 'none',
      background: 'var(--attention-bg)',
      color: 'var(--attention-fg)',
      display: 'grid',
      placeItems: 'center',
      cursor: 'pointer'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "trash-2",
    size: 19
  })), /*#__PURE__*/React.createElement("div", {
    onClick: swiped ? onSwipe : onPress,
    style: {
      position: 'relative',
      display: 'flex',
      alignItems: 'center',
      gap: 'var(--space-4)',
      minHeight: 72,
      padding: 'var(--space-4) var(--space-5)',
      background: 'var(--bg-raised)',
      cursor: 'pointer',
      borderBottom: divider ? '1px solid var(--line-hairline)' : 'none',
      transform: swiped ? 'translateX(-92px)' : 'none',
      transition: 'transform var(--dur-normal) var(--ease-exhale)'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.DestinationBadge, {
    destination: destination,
    variant: "glyph"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0,
      display: 'flex',
      flexDirection: 'column',
      gap: 3
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-body)',
      color: 'var(--text-primary)',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap'
    }
  }, title), /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-footnote)',
      color: 'var(--text-secondary)'
    }
  }, destination === 'event' ? 'Event' : 'Reminder', when ? ` · ${when}` : '')), relative ? /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-meta)',
      fontSize: 12,
      color: 'var(--text-tertiary)',
      flex: '0 0 auto'
    }
  }, relative) : null, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "chevron-right",
    size: 16,
    style: {
      color: 'var(--text-tertiary)',
      opacity: .6
    }
  })));
}
Object.assign(__ds_scope, { HistoryRow });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data/HistoryRow.jsx", error: String((e && e.message) || e) }); }

// components/data/PermissionRow.jsx
try { (() => {
/**
 * PermissionRow — states plainly whether Murmur has what it needs. Granted is
 * quiet; needs-attention is warm clay, never alarming red.
 */
function PermissionRow({
  label,
  status = 'granted',
  hint,
  onFix,
  divider = true,
  style
}) {
  const ok = status === 'granted';
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 'var(--space-4)',
      minHeight: 'var(--hit-comfort)',
      padding: 'var(--space-4) var(--space-5)',
      borderBottom: divider ? '1px solid var(--line-hairline)' : 'none',
      ...style
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 26,
      height: 26,
      borderRadius: '50%',
      display: 'grid',
      placeItems: 'center',
      flex: '0 0 auto',
      background: ok ? 'var(--success-bg)' : 'var(--attention-bg)',
      color: ok ? 'var(--success-fg)' : 'var(--attention-fg)'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: ok ? 'check' : 'circle-alert',
    size: 14,
    title: ok ? 'Granted' : 'Needs attention'
  })), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      minWidth: 0,
      display: 'flex',
      flexDirection: 'column',
      gap: 2
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-body)',
      color: 'var(--text-primary)'
    }
  }, label), /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-footnote)',
      color: ok ? 'var(--text-tertiary)' : 'var(--attention-fg)'
    }
  }, hint || (ok ? 'Allowed' : 'Not allowed yet'))), !ok && onFix ? /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onFix,
    style: {
      border: '1px solid var(--line-soft)',
      background: 'transparent',
      color: 'var(--text-primary)',
      borderRadius: 'var(--radius-pill)',
      minHeight: 36,
      padding: '0 var(--space-5)',
      font: 'var(--type-footnote)',
      cursor: 'pointer'
    }
  }, "Allow") : null);
}
Object.assign(__ds_scope, { PermissionRow });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data/PermissionRow.jsx", error: String((e && e.message) || e) }); }

// components/fields/DestinationToggle.jsx
try { (() => {
const OPTIONS = [{
  id: 'reminder',
  label: 'Reminder',
  icon: 'bell',
  fg: 'var(--reminder-fg)',
  bg: 'var(--reminder-bg)'
}, {
  id: 'event',
  label: 'Event',
  icon: 'calendar',
  fg: 'var(--event-fg)',
  bg: 'var(--event-bg)'
}];

/**
 * DestinationToggle — where the thought lands. Two options only, each carrying
 * icon + word + its own tint, so it never depends on color alone.
 */
function DestinationToggle({
  value = 'reminder',
  onChange,
  size = 'md',
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    role: "radiogroup",
    style: {
      display: 'flex',
      gap: 'var(--space-2)',
      padding: 'var(--space-1)',
      background: 'var(--bg-sunk)',
      borderRadius: 'var(--radius-pill)',
      ...style
    }
  }, OPTIONS.map(o => {
    const on = value === o.id;
    return /*#__PURE__*/React.createElement("button", {
      key: o.id,
      type: "button",
      role: "radio",
      "aria-checked": on,
      onClick: () => onChange && onChange(o.id),
      style: {
        flex: 1,
        display: 'inline-flex',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 'var(--space-3)',
        minHeight: size === 'sm' ? 38 : 46,
        padding: '0 var(--space-5)',
        border: `1px solid ${on ? o.fg : 'transparent'}`,
        borderRadius: 'var(--radius-pill)',
        background: on ? o.bg : 'transparent',
        color: on ? o.fg : 'var(--text-secondary)',
        font: on ? 'var(--type-subhead)' : 'var(--weight-regular) var(--size-subhead)/1.38 var(--font-core)',
        cursor: 'pointer',
        WebkitTapHighlightColor: 'transparent',
        transition: 'background var(--dur-quick) var(--ease-exhale), color var(--dur-quick) var(--ease-exhale), border-color var(--dur-quick) var(--ease-exhale)'
      }
    }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: o.icon,
      size: 16
    }), o.label);
  }));
}
Object.assign(__ds_scope, { DestinationToggle });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/fields/DestinationToggle.jsx", error: String((e && e.message) || e) }); }

// components/fields/EditableField.jsx
try { (() => {
/**
 * EditableField — a parsed value the user can glance at and fix. Resting state is
 * plain text with a quiet pencil; editing lifts the field onto a raised surface
 * with an ember hairline. Rows are 60px so they clear the 44px minimum with air.
 */
function EditableField({
  label,
  value,
  placeholder = 'Not set',
  icon,
  editing,
  muted,
  onPress,
  onChange,
  children,
  style
}) {
  const shown = value || placeholder;
  return /*#__PURE__*/React.createElement("div", {
    onClick: editing ? undefined : onPress,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 'var(--space-4)',
      minHeight: 60,
      padding: '10px var(--space-5)',
      background: editing ? 'var(--bg-raised)' : 'transparent',
      border: `1px solid ${editing ? 'var(--accent)' : 'transparent'}`,
      borderRadius: 'var(--radius-md)',
      cursor: editing ? 'default' : 'pointer',
      transition: 'background var(--dur-normal) var(--ease-exhale), border-color var(--dur-normal) var(--ease-exhale)',
      ...style
    }
  }, icon ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 19,
    style: {
      color: 'var(--text-tertiary)'
    }
  }) : null, /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0,
      display: 'flex',
      flexDirection: 'column',
      gap: 2
    }
  }, label ? /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-caption)',
      color: 'var(--text-tertiary)',
      textTransform: 'uppercase',
      letterSpacing: '.08em'
    }
  }, label) : null, editing && children ? children : editing ? /*#__PURE__*/React.createElement("input", {
    autoFocus: true,
    value: value || '',
    onChange: e => onChange && onChange(e.target.value),
    style: {
      font: 'var(--type-body)',
      color: 'var(--text-primary)',
      background: 'none',
      border: 'none',
      outline: 'none',
      padding: 0,
      width: '100%'
    }
  }) : /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-body)',
      color: value ? muted ? 'var(--text-secondary)' : 'var(--text-primary)' : 'var(--text-tertiary)',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap'
    }
  }, shown)), !editing ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "pencil",
    size: 16,
    style: {
      color: 'var(--text-tertiary)',
      opacity: .65
    }
  }) : null);
}
Object.assign(__ds_scope, { EditableField });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/fields/EditableField.jsx", error: String((e && e.message) || e) }); }

// components/fields/ToggleRow.jsx
try { (() => {
/**
 * ToggleRow — a settings preference. The switch is skinned in ember but the row
 * stays quiet; the label carries the meaning, the description carries the why.
 */
function ToggleRow({
  label,
  description,
  checked,
  onChange,
  divider = true,
  style
}) {
  return /*#__PURE__*/React.createElement("label", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 'var(--space-5)',
      minHeight: 'var(--hit-comfort)',
      padding: 'var(--space-4) var(--space-5)',
      borderBottom: divider ? '1px solid var(--line-hairline)' : 'none',
      cursor: 'pointer',
      ...style
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      minWidth: 0,
      display: 'flex',
      flexDirection: 'column',
      gap: 3
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-body)',
      color: 'var(--text-primary)'
    }
  }, label), description ? /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-footnote)',
      color: 'var(--text-tertiary)'
    }
  }, description) : null), /*#__PURE__*/React.createElement("span", {
    role: "switch",
    "aria-checked": !!checked,
    onClick: e => {
      e.preventDefault();
      onChange && onChange(!checked);
    },
    style: {
      position: 'relative',
      width: 52,
      height: 32,
      flex: '0 0 auto',
      borderRadius: 'var(--radius-pill)',
      background: checked ? 'var(--accent)' : 'var(--line-soft)',
      transition: 'background var(--dur-quick) var(--ease-exhale)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      position: 'absolute',
      top: 3,
      left: checked ? 23 : 3,
      width: 26,
      height: 26,
      borderRadius: '50%',
      background: 'var(--bg-raised)',
      boxShadow: 'var(--shadow-row)',
      transition: 'left var(--dur-quick) var(--ease-exhale)'
    }
  })));
}
Object.assign(__ds_scope, { ToggleRow });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/fields/ToggleRow.jsx", error: String((e && e.message) || e) }); }

// ui_kits/murmur-ios/App.jsx
try { (() => {
const P = new URLSearchParams(location.search);
const STATES = [['Onboarding', ['onboarding-1', 'onboarding-2', 'onboarding-3']], ['Home Screen', ['springboard']], ['Capture', ['capture-first-run', 'capture-idle', 'capture-listening', 'capture-thinking', 'capture-success']], ['Confirmation', ['confirm', 'confirm-editing']], ['Clarification', ['clarify', 'clarify-answered']], ['History', ['history', 'history-empty']], ['Settings', ['settings']]];
const LABELS = {
  'onboarding-1': 'Slide 1 · what it does',
  'onboarding-2': 'Slide 2 · permissions',
  'onboarding-3': 'Slide 3 · hands-free',
  springboard: 'Icon on the Home Screen',
  'capture-first-run': 'First run',
  'capture-idle': 'Idle',
  'capture-listening': 'Listening',
  'capture-thinking': 'Processing',
  'capture-success': 'Success + Undo',
  confirm: 'Confident case',
  'confirm-editing': 'Correcting a field',
  clarify: 'Listening for the answer',
  'clarify-answered': 'Answer received',
  history: 'Populated',
  'history-empty': 'Empty',
  settings: 'Settings'
};
function App() {
  const [screen, setScreen] = React.useState(P.get('screen') || 'capture-idle');
  const [editing, setEditing] = React.useState(P.get('screen') === 'confirm-editing' ? 'when' : null);
  const [dest, setDest] = React.useState('reminder');
  const [dark, setDark] = React.useState(P.get('theme') === 'dark');
  const chrome = P.get('chrome') !== '0';
  React.useEffect(() => {
    document.documentElement.dataset.theme = dark ? 'dark' : 'light';
  }, [dark]);

  // idle → listening → thinking → confirmation, on the app's own clock
  React.useEffect(() => {
    if (!chrome) return;
    if (screen === 'capture-listening') {
      const t = setTimeout(() => setScreen('capture-thinking'), 4600);
      return () => clearTimeout(t);
    }
    if (screen === 'capture-thinking') {
      const t = setTimeout(() => setScreen('confirm'), 1500);
      return () => clearTimeout(t);
    }
    if (screen === 'capture-success') {
      const t = setTimeout(() => setScreen('capture-idle'), 5000);
      return () => clearTimeout(t);
    }
  }, [screen, chrome]);
  const go = s => {
    setScreen(s);
    setEditing(s === 'confirm-editing' ? 'when' : null);
  };
  const captureState = screen.startsWith('capture-') ? screen.slice(8) : 'idle';
  const onConfirm = screen.startsWith('confirm');
  let body;
  if (screen.startsWith('onboarding')) {
    const i = Number(screen.slice(-1)) - 1;
    body = /*#__PURE__*/React.createElement(OnboardingScreen, {
      index: i,
      onNext: () => go(i < 2 ? `onboarding-${i + 2}` : 'capture-first-run'),
      onSkip: () => go('capture-first-run')
    });
  } else if (screen === 'springboard') {
    body = /*#__PURE__*/React.createElement(SpringboardScreen, {
      onOpen: () => go('capture-idle')
    });
  } else if (screen.startsWith('clarify')) {
    body = /*#__PURE__*/React.createElement(ClarifyScreen, {
      answered: screen === 'clarify-answered',
      onBack: () => go('capture-idle')
    });
  } else if (screen.startsWith('history')) {
    body = /*#__PURE__*/React.createElement(HistoryScreen, {
      empty: screen === 'history-empty',
      onBack: () => go('capture-idle')
    });
  } else if (screen === 'settings') {
    body = /*#__PURE__*/React.createElement(SettingsScreen, {
      onBack: () => go('capture-idle')
    });
  } else {
    body = /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(CaptureScreen, {
      state: onConfirm ? 'thinking' : captureState,
      onTap: () => go(captureState === 'listening' ? 'capture-thinking' : 'capture-listening'),
      onHistory: () => go('history'),
      onSettings: () => go('settings')
    }), onConfirm ? /*#__PURE__*/React.createElement(ConfirmSheet, {
      editing: editing,
      destination: dest,
      onEdit: f => setEditing(e => e === f ? null : f),
      onDestination: setDest,
      onSave: () => go('capture-success'),
      onCancel: () => go('capture-idle')
    }) : null);
  }
  const phone = /*#__PURE__*/React.createElement(Phone, {
    wash: screen.startsWith('capture') || onConfirm || screen.startsWith('clarify') || screen.startsWith('onboarding')
  }, body);
  if (!chrome) return phone;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 44,
      alignItems: 'flex-start'
    }
  }, /*#__PURE__*/React.createElement("aside", {
    style: {
      width: 246,
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--space-6)',
      paddingTop: 8
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between'
    }
  }, /*#__PURE__*/React.createElement(Wordmark, {
    size: 22
  }), /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: () => setDark(d => !d),
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 8,
      border: '1px solid var(--line-soft)',
      background: 'var(--bg-raised)',
      color: 'var(--text-secondary)',
      borderRadius: 99,
      padding: '7px 13px',
      font: 'var(--type-footnote)',
      cursor: 'pointer'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: dark ? 'sun' : 'moon',
    size: 14
  }), dark ? 'Light' : 'Dark')), STATES.map(([group, items]) => /*#__PURE__*/React.createElement("div", {
    key: group,
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 6
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-caption)',
      textTransform: 'uppercase',
      letterSpacing: '.08em',
      color: 'var(--text-tertiary)'
    }
  }, group), items.map(s => {
    const on = s === screen;
    return /*#__PURE__*/React.createElement("button", {
      key: s,
      type: "button",
      onClick: () => go(s),
      style: {
        textAlign: 'left',
        border: '1px solid',
        borderColor: on ? 'var(--accent)' : 'transparent',
        background: on ? 'var(--accent-quiet)' : 'transparent',
        color: on ? 'var(--text-accent)' : 'var(--text-secondary)',
        borderRadius: 'var(--radius-sm)',
        padding: '9px 12px',
        font: 'var(--type-footnote)',
        cursor: 'pointer'
      }
    }, LABELS[s]);
  }))), /*#__PURE__*/React.createElement("a", {
    href: "gallery.html",
    style: {
      font: 'var(--type-footnote)'
    }
  }, "Every screen, both modes \u2192")), phone);
}
ReactDOM.createRoot(document.getElementById('root')).render(/*#__PURE__*/React.createElement(App, null));
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/murmur-ios/App.jsx", error: String((e && e.message) || e) }); }

// ui_kits/murmur-ios/CaptureScreen.jsx
try { (() => {
const {
  CaptureBloom,
  Transcript,
  SuccessBar,
  Button
} = window.MurmurDesignSystem_545ca7;

/** Simulated, smoothed mic amplitude — the real app feeds this from the audio tap. */
function useLevel(active) {
  const [level, setLevel] = React.useState(0);
  React.useEffect(() => {
    if (!active) {
      setLevel(0);
      return;
    }
    let t = 0;
    const id = setInterval(() => {
      t += 0.08;
      const raw = 0.5 + 0.42 * Math.sin(t) * Math.sin(t * 0.41) + 0.06 * Math.sin(t * 4.3);
      setLevel(p => p + (Math.max(0, Math.min(1, raw)) - p) * 0.3);
    }, 60);
    return () => clearInterval(id);
  }, [active]);
  return level;
}
const SPOKEN = ['Remind me', 'Remind me to call mom', 'Remind me to call mom tomorrow', 'Remind me to call mom tomorrow at five'];
function CaptureScreen({
  state = 'idle',
  onTap,
  onHistory,
  onSettings
}) {
  const level = useLevel(state === 'listening');
  const [step, setStep] = React.useState(0);
  React.useEffect(() => {
    if (state !== 'listening') {
      setStep(0);
      return;
    }
    const id = setInterval(() => setStep(s => (s + 1) % (SPOKEN.length + 1)), 1400);
    return () => clearInterval(id);
  }, [state]);
  const firstRun = state === 'first-run';
  const bloomState = state === 'first-run' ? 'idle' : state === 'success' ? 'done' : state;
  const label = {
    idle: 'Tap to speak',
    'first-run': 'Tap, then just say it',
    listening: 'Listening',
    thinking: 'One moment',
    success: 'Saved'
  }[state];
  const spoken = SPOKEN[Math.max(0, Math.min(SPOKEN.length - 1, step - 1))];
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '0 var(--space-4)',
      flex: '0 0 auto'
    }
  }, /*#__PURE__*/React.createElement(IconButton, {
    name: "list",
    label: "History",
    onClick: onHistory
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--weight-medium) 16px/1 var(--font-core)',
      color: 'var(--text-secondary)',
      letterSpacing: '.14em'
    }
  }, "Murmur"), /*#__PURE__*/React.createElement(IconButton, {
    name: "settings",
    label: "Settings",
    onClick: onSettings
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 'var(--space-9)',
      padding: '0 var(--gutter-screen) var(--space-10)'
    }
  }, firstRun ? /*#__PURE__*/React.createElement("p", {
    style: {
      margin: 0,
      font: 'var(--type-title)',
      letterSpacing: 'var(--ls-title)',
      textAlign: 'center',
      maxWidth: '18ch',
      color: 'var(--text-primary)'
    }
  }, "Say what you need to remember.") : /*#__PURE__*/React.createElement("div", {
    style: {
      minHeight: 108,
      display: 'flex',
      alignItems: 'flex-end'
    }
  }, state === 'listening' ? /*#__PURE__*/React.createElement(Transcript, {
    text: step > 1 ? SPOKEN[step - 2] : '',
    partial: step > 0 ? spoken.replace(step > 1 ? SPOKEN[step - 2] : '', '').trim() : '',
    placeholder: "I'm listening\u2026"
  }) : state === 'thinking' ? /*#__PURE__*/React.createElement(Transcript, {
    text: "Remind me to call mom tomorrow at five",
    style: {
      color: 'var(--text-secondary)'
    }
  }) : state === 'success' ? /*#__PURE__*/React.createElement(Transcript, {
    text: "Call mom",
    style: {
      fontSize: 22
    }
  }) : null), /*#__PURE__*/React.createElement(CaptureBloom, {
    state: bloomState,
    level: level,
    size: 244,
    onTap: onTap,
    label: label
  }), firstRun ? /*#__PURE__*/React.createElement("p", {
    style: {
      margin: 0,
      font: 'var(--type-footnote)',
      color: 'var(--text-tertiary)',
      textAlign: 'center',
      maxWidth: '26ch'
    }
  }, "Murmur files it as a reminder or an event. You can always check before it saves.") : /*#__PURE__*/React.createElement("div", {
    style: {
      height: 18
    }
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '0 var(--gutter-screen)',
      minHeight: 76,
      flex: '0 0 auto'
    }
  }, state === 'success' ? /*#__PURE__*/React.createElement(SuccessBar, {
    message: "Saved to Reminders \xB7 tomorrow 5:00 PM",
    destination: "reminder",
    onUndo: () => {}
  }) : null), /*#__PURE__*/React.createElement(HomeIndicator, null));
}
Object.assign(window, {
  CaptureScreen,
  useLevel
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/murmur-ios/CaptureScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/murmur-ios/ClarifyScreen.jsx
try { (() => {
const {
  CaptureBloom,
  Transcript,
  Button,
  DestinationToggle
} = window.MurmurDesignSystem_545ca7;

/** Clarification — Murmur asked out loud and is listening for the answer. */
function ClarifyScreen({
  onBack,
  answered
}) {
  const level = useLevel(!answered);
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement(NavBar, {
    onBack: onBack,
    title: ""
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      display: 'flex',
      flexDirection: 'column',
      padding: '0 var(--gutter-screen)',
      gap: 'var(--space-8)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--space-4)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 8,
      font: 'var(--type-caption)',
      textTransform: 'uppercase',
      letterSpacing: '.08em',
      color: 'var(--text-tertiary)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "volume-2",
    size: 14
  }), "Murmur asked"), /*#__PURE__*/React.createElement("p", {
    style: {
      margin: 0,
      font: 'var(--type-title)',
      letterSpacing: 'var(--ls-title)',
      maxWidth: '20ch'
    }
  }, "Which day did you mean \u2014 Friday or Saturday?")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-start',
      gap: 'var(--space-5)'
    }
  }, /*#__PURE__*/React.createElement(CaptureBloom, {
    state: answered ? 'thinking' : 'listening',
    level: level,
    size: 64
  }), /*#__PURE__*/React.createElement(Transcript, {
    align: "left",
    text: answered ? 'Friday, the early one' : 'Friday',
    partial: answered ? '' : ', the early…',
    placeholder: "I'm listening\u2026",
    style: {
      fontSize: 22,
      maxWidth: '18ch'
    }
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 'auto',
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--space-4)',
      paddingBottom: 'var(--space-6)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-footnote)',
      color: 'var(--text-tertiary)'
    }
  }, "Somewhere quiet? Tap an answer instead."), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 'var(--space-3)'
    }
  }, /*#__PURE__*/React.createElement(Button, {
    variant: "secondary",
    size: "md",
    fullWidth: true
  }, "Friday"), /*#__PURE__*/React.createElement(Button, {
    variant: "secondary",
    size: "md",
    fullWidth: true
  }, "Saturday")), /*#__PURE__*/React.createElement(Button, {
    variant: "ghost",
    size: "md",
    fullWidth: true,
    onClick: onBack
  }, "Start over"))), /*#__PURE__*/React.createElement(HomeIndicator, null));
}
Object.assign(window, {
  ClarifyScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/murmur-ios/ClarifyScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/murmur-ios/ConfirmSheet.jsx
try { (() => {
const {
  EditableField,
  DestinationToggle,
  Button,
  CaptureBloom
} = window.MurmurDesignSystem_545ca7;

/** Skin over the system DatePicker — behaviour stays native, only the paint changes. */
function DateWheel() {
  const cols = [['Today', 'Tomorrow', 'Fri 22 Aug'], ['4', '5', '6'], ['00', '15', '30'], ['AM', 'PM']];
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      display: 'flex',
      gap: 'var(--space-5)',
      height: 116,
      marginTop: 'var(--space-2)',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      left: 0,
      right: 0,
      top: 40,
      height: 36,
      borderRadius: 'var(--radius-sm)',
      background: 'var(--accent-quiet)'
    }
  }), cols.map((c, i) => /*#__PURE__*/React.createElement("div", {
    key: i,
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 8,
      alignItems: 'center',
      paddingTop: 8
    }
  }, c.map((v, j) => /*#__PURE__*/React.createElement("span", {
    key: v,
    style: {
      font: j === 1 ? 'var(--type-body-em)' : 'var(--type-body)',
      color: j === 1 ? 'var(--text-primary)' : 'var(--text-tertiary)',
      opacity: j === 1 ? 1 : .7,
      height: 28,
      display: 'flex',
      alignItems: 'center'
    }
  }, v)))));
}
function ConfirmSheet({
  editing = null,
  destination = 'reminder',
  onEdit,
  onSave,
  onCancel,
  onDestination
}) {
  const [title, setTitle] = React.useState('Call mom');
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      display: 'flex',
      flexDirection: 'column',
      justifyContent: 'flex-end'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      background: 'var(--bg-overlay)'
    },
    onClick: onCancel
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      background: 'var(--bg-base)',
      borderRadius: 'var(--radius-xl) var(--radius-xl) 0 0',
      boxShadow: 'var(--shadow-sheet)',
      padding: 'var(--space-5) var(--gutter-sheet) var(--space-5)',
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--space-5)',
      animation: 'mm-rise var(--dur-normal) var(--ease-exhale)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 40,
      height: 4,
      borderRadius: 99,
      background: 'var(--line-soft)',
      alignSelf: 'center'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 'var(--space-4)'
    }
  }, /*#__PURE__*/React.createElement(CaptureBloom, {
    state: "done",
    size: 44
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-headline)'
    }
  }, editing ? 'Fix it up' : 'Does this look right?'), /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-footnote)',
      color: 'var(--text-tertiary)'
    }
  }, "Tap anything to change it."))), /*#__PURE__*/React.createElement("div", {
    style: {
      background: 'var(--bg-raised)',
      border: '1px solid var(--line-hairline)',
      borderRadius: 'var(--radius-lg)',
      padding: 6,
      display: 'flex',
      flexDirection: 'column'
    }
  }, /*#__PURE__*/React.createElement(EditableField, {
    label: "Title",
    value: title,
    onChange: setTitle,
    editing: editing === 'title',
    onPress: () => onEdit('title')
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 1,
      background: 'var(--line-hairline)',
      margin: '0 var(--space-5)'
    }
  }), /*#__PURE__*/React.createElement(EditableField, {
    label: "When",
    icon: "clock",
    value: "Tomorrow, 5:00 PM",
    editing: editing === 'when',
    onPress: () => onEdit('when')
  }, /*#__PURE__*/React.createElement(DateWheel, null)), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 1,
      background: 'var(--line-hairline)',
      margin: '0 var(--space-5)'
    }
  }), /*#__PURE__*/React.createElement(EditableField, {
    label: "Goes to",
    icon: destination === 'event' ? 'calendar' : 'bell',
    value: destination === 'event' ? 'Calendar · Personal' : 'Reminders · Inbox',
    editing: editing === 'dest',
    onPress: () => onEdit('dest')
  }, /*#__PURE__*/React.createElement(DestinationToggle, {
    value: destination,
    onChange: onDestination,
    size: "sm",
    style: {
      marginTop: 6
    }
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--space-3)'
    }
  }, /*#__PURE__*/React.createElement(Button, {
    variant: "primary",
    fullWidth: true,
    onClick: onSave
  }, destination === 'event' ? 'Save event' : 'Save reminder'), /*#__PURE__*/React.createElement(Button, {
    variant: "ghost",
    size: "md",
    fullWidth: true,
    onClick: onCancel
  }, "Cancel")), /*#__PURE__*/React.createElement(HomeIndicator, null)));
}
Object.assign(window, {
  ConfirmSheet,
  DateWheel
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/murmur-ios/ConfirmSheet.jsx", error: String((e && e.message) || e) }); }

// ui_kits/murmur-ios/ListScreens.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const {
  HistoryRow,
  EmptyState,
  Button,
  ToggleRow,
  PermissionRow,
  DestinationToggle
} = window.MurmurDesignSystem_545ca7;
const ITEMS = [{
  title: 'Call mom',
  destination: 'reminder',
  when: 'Tomorrow, 5:00 PM',
  relative: '2h ago',
  day: 'Today'
}, {
  title: 'Coffee with Ana',
  destination: 'event',
  when: 'Fri, 9:30 AM',
  relative: '5h ago',
  day: 'Today'
}, {
  title: 'Buy cat food',
  destination: 'reminder',
  relative: '9h ago',
  day: 'Today'
}, {
  title: 'Dentist',
  destination: 'event',
  when: 'Mon 25, 8:00 AM',
  relative: 'Yesterday',
  day: 'Yesterday'
}, {
  title: 'Move the car before street cleaning',
  destination: 'reminder',
  when: 'Wed, 7:00 AM',
  relative: 'Yesterday',
  day: 'Yesterday'
}];
function HistoryScreen({
  empty,
  onBack
}) {
  const [swiped, setSwiped] = React.useState(null);
  const days = ['Today', 'Yesterday'];
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement(NavBar, {
    title: "History",
    onBack: onBack
  }), empty ? /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      display: 'grid',
      placeItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(EmptyState, {
    icon: "list",
    title: "Nothing captured yet",
    body: "Tap the well on the home screen and say the thing you keep almost forgetting.",
    action: /*#__PURE__*/React.createElement(Button, {
      variant: "secondary",
      size: "md",
      onClick: onBack
    }, "Capture something")
  })) : /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      padding: '0 var(--gutter-screen) var(--space-8)',
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--space-7)'
    }
  }, days.map(day => /*#__PURE__*/React.createElement(Group, {
    key: day,
    title: day
  }, ITEMS.filter(i => i.day === day).map((i, idx, arr) => /*#__PURE__*/React.createElement(HistoryRow, _extends({
    key: i.title
  }, i, {
    divider: idx < arr.length - 1,
    swiped: swiped === i.title,
    onPress: () => setSwiped(i.title),
    onSwipe: () => setSwiped(null),
    onDelete: () => setSwiped(null)
  }))))), /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-footnote)',
      color: 'var(--text-tertiary)',
      textAlign: 'center'
    }
  }, "Tap a row to swipe it aside, then delete.")), /*#__PURE__*/React.createElement(HomeIndicator, null));
}
function SettingsScreen({
  onBack
}) {
  const [confirm, setConfirm] = React.useState(true);
  const [speak, setSpeak] = React.useState(true);
  const [dest, setDest] = React.useState('reminder');
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement(NavBar, {
    title: "Settings",
    onBack: onBack
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      padding: '0 var(--gutter-screen) var(--space-8)',
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--space-7)'
    }
  }, /*#__PURE__*/React.createElement(Group, {
    title: "Capture"
  }, /*#__PURE__*/React.createElement(ToggleRow, {
    label: "Always confirm before saving",
    description: "Glance at what Murmur heard before it files it.",
    checked: confirm,
    onChange: setConfirm
  }), /*#__PURE__*/React.createElement(ToggleRow, {
    label: "Speak questions aloud",
    description: "When something's unclear, Murmur asks out loud.",
    checked: speak,
    onChange: setSpeak,
    divider: false
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--space-3)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-caption)',
      textTransform: 'uppercase',
      letterSpacing: '.08em',
      color: 'var(--text-tertiary)',
      padding: '0 var(--space-4)'
    }
  }, "Default destination"), /*#__PURE__*/React.createElement(DestinationToggle, {
    value: dest,
    onChange: setDest
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-footnote)',
      color: 'var(--text-tertiary)',
      padding: '0 var(--space-4)'
    }
  }, "Used when what you say has no obvious time attached.")), /*#__PURE__*/React.createElement(Group, {
    title: "Permissions"
  }, /*#__PURE__*/React.createElement(PermissionRow, {
    label: "Microphone",
    status: "granted"
  }), /*#__PURE__*/React.createElement(PermissionRow, {
    label: "Reminders",
    status: "granted"
  }), /*#__PURE__*/React.createElement(PermissionRow, {
    label: "Calendar",
    status: "needed",
    hint: "Needed to save events",
    onFix: () => {},
    divider: false
  })), /*#__PURE__*/React.createElement(Group, {
    title: "Hands-free"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 'var(--space-4)',
      minHeight: 'var(--hit-comfort)',
      padding: 'var(--space-4) var(--space-5)',
      cursor: 'pointer'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "mic",
    size: 19,
    style: {
      color: 'var(--text-tertiary)'
    }
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      display: 'flex',
      flexDirection: 'column',
      gap: 2
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-body)'
    }
  }, "Set up Action Button launch"), /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-footnote)',
      color: 'var(--text-tertiary)'
    }
  }, "Three steps, about a minute")), /*#__PURE__*/React.createElement(Icon, {
    name: "chevron-right",
    size: 16,
    style: {
      color: 'var(--text-tertiary)'
    }
  }))), /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-meta)',
      fontSize: 11,
      color: 'var(--text-tertiary)',
      textAlign: 'center'
    }
  }, "murmur 1.0 (12)")), /*#__PURE__*/React.createElement(HomeIndicator, null));
}
Object.assign(window, {
  HistoryScreen,
  SettingsScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/murmur-ios/ListScreens.jsx", error: String((e && e.message) || e) }); }

// ui_kits/murmur-ios/OnboardingScreen.jsx
try { (() => {
const {
  Button,
  CaptureBloom,
  PermissionRow,
  Wordmark: WM,
  AppIcon: AI
} = window.MurmurDesignSystem_545ca7;
const SLIDES = [{
  kind: 'intro',
  title: 'Say it once. It\u2019s kept.',
  body: 'Speak a thought the way you\u2019d say it to a person. Murmur files it as a reminder or an event.',
  cta: 'Next'
}, {
  kind: 'permissions',
  title: 'Two things to allow',
  body: 'Your microphone, so Murmur can hear you. Reminders and Calendar, so it has somewhere to put things. Nothing leaves your phone unasked.',
  cta: 'Allow access'
}, {
  kind: 'handsfree',
  title: 'One press, hands free',
  body: 'Put Murmur on the Action Button and capture without looking. You can set this up later in Settings.',
  cta: 'Set it up'
}];
function OnboardingScreen({
  index = 0,
  onNext,
  onSkip
}) {
  const s = SLIDES[index];
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      justifyContent: 'flex-end',
      padding: '0 var(--space-4)'
    }
  }, /*#__PURE__*/React.createElement(Button, {
    variant: "ghost",
    size: "sm",
    onClick: onSkip
  }, "Skip")), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      display: 'flex',
      flexDirection: 'column',
      justifyContent: 'center',
      gap: 'var(--space-9)',
      padding: '0 var(--gutter-screen)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      placeItems: 'center',
      minHeight: 220
    }
  }, s.kind === 'intro' ? /*#__PURE__*/React.createElement(CaptureBloom, {
    state: "idle",
    size: 196
  }) : s.kind === 'permissions' ? /*#__PURE__*/React.createElement("div", {
    style: {
      width: '100%',
      background: 'var(--bg-raised)',
      border: '1px solid var(--line-hairline)',
      borderRadius: 'var(--radius-lg)',
      overflow: 'hidden'
    }
  }, /*#__PURE__*/React.createElement(PermissionRow, {
    label: "Microphone",
    status: "needed",
    hint: "So Murmur can hear you"
  }), /*#__PURE__*/React.createElement(PermissionRow, {
    label: "Reminders",
    status: "needed",
    hint: "Somewhere to keep tasks"
  }), /*#__PURE__*/React.createElement(PermissionRow, {
    label: "Calendar",
    status: "needed",
    hint: "Somewhere to keep events",
    divider: false
  })) : /*#__PURE__*/React.createElement(AI, {
    size: 132
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--space-4)'
    }
  }, /*#__PURE__*/React.createElement("h1", {
    style: {
      margin: 0,
      font: 'var(--type-display)',
      letterSpacing: 'var(--ls-display)',
      maxWidth: '16ch'
    }
  }, s.title), /*#__PURE__*/React.createElement("p", {
    style: {
      margin: 0,
      font: 'var(--type-callout)',
      color: 'var(--text-secondary)',
      maxWidth: '30ch'
    }
  }, s.body))), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '0 var(--gutter-screen) var(--space-5)',
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--space-5)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 6,
      justifyContent: 'center'
    }
  }, SLIDES.map((_, i) => /*#__PURE__*/React.createElement("span", {
    key: i,
    style: {
      width: i === index ? 20 : 6,
      height: 6,
      borderRadius: 99,
      background: i === index ? 'var(--accent)' : 'var(--line-soft)',
      transition: 'width var(--dur-normal) var(--ease-exhale)'
    }
  }))), /*#__PURE__*/React.createElement(Button, {
    variant: "primary",
    fullWidth: true,
    onClick: onNext
  }, s.cta)), /*#__PURE__*/React.createElement(HomeIndicator, null));
}

/** iOS Home Screen — the icon in its real habitat, light and dark. */
function SpringboardScreen({
  onOpen
}) {
  const apps = ['Calendar', 'Notes', 'Weather', 'Photos', 'Clock', 'Maps'];
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      padding: 'var(--space-8) var(--space-7)',
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--space-8)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: 'repeat(4, 1fr)',
      gap: 'var(--space-7) var(--space-5)'
    }
  }, /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onOpen,
    style: {
      border: 'none',
      background: 'none',
      padding: 0,
      cursor: 'pointer',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      gap: 7
    }
  }, /*#__PURE__*/React.createElement(AI, {
    size: 66
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--weight-regular) 11px/1.2 var(--font-core)',
      color: 'var(--text-primary)'
    }
  }, "murmur")), apps.map(a => /*#__PURE__*/React.createElement("span", {
    key: a,
    style: {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      gap: 7
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 66,
      height: 66,
      borderRadius: 'var(--radius-icon)',
      background: 'var(--bg-sunk)',
      border: '1px solid var(--line-hairline)'
    }
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--weight-regular) 11px/1.2 var(--font-core)',
      color: 'var(--text-tertiary)'
    }
  }, a)))), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 'auto',
      display: 'flex',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-footnote)',
      color: 'var(--text-tertiary)'
    }
  }, "Home Screen \xB7 icon at 66px"))), /*#__PURE__*/React.createElement(HomeIndicator, null));
}
Object.assign(window, {
  OnboardingScreen,
  SpringboardScreen,
  SLIDES
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/murmur-ios/OnboardingScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/murmur-ios/Phone.jsx
try { (() => {
const {
  Icon,
  IconButton,
  Wordmark,
  AppIcon
} = window.MurmurDesignSystem_545ca7;
function StatusBar({
  time = '9:41'
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      height: 54,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '0 30px',
      position: 'relative',
      flex: '0 0 auto'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--weight-semibold) 15px/1 var(--font-core)',
      color: 'var(--text-primary)',
      letterSpacing: '-.01em'
    }
  }, time), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      left: '50%',
      top: 10,
      transform: 'translateX(-50%)',
      width: 118,
      height: 34,
      borderRadius: 99,
      background: '#000'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-end',
      gap: 5
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'flex-end',
      gap: 2
    }
  }, [5, 7, 9, 11].map(h => /*#__PURE__*/React.createElement("i", {
    key: h,
    style: {
      display: 'block',
      width: 3,
      height: h,
      borderRadius: 1,
      background: 'var(--text-primary)'
    }
  }))), /*#__PURE__*/React.createElement("span", {
    style: {
      width: 25,
      height: 12,
      borderRadius: 3.5,
      border: '1px solid var(--line-strong)',
      padding: 1.5,
      display: 'block'
    }
  }, /*#__PURE__*/React.createElement("i", {
    style: {
      display: 'block',
      height: '100%',
      width: '72%',
      borderRadius: 2,
      background: 'var(--text-primary)'
    }
  }))));
}
function HomeIndicator() {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      height: 26,
      display: 'grid',
      placeItems: 'center',
      flex: '0 0 auto'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 138,
      height: 5,
      borderRadius: 99,
      background: 'var(--text-primary)',
      opacity: .28
    }
  }));
}

/** Quiet iOS nav bar: back chevron, centred title, optional trailing action. */
function NavBar({
  title,
  onBack,
  trailing
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      height: 50,
      display: 'flex',
      alignItems: 'center',
      padding: '0 var(--space-4)',
      gap: 'var(--space-2)',
      flex: '0 0 auto'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 44
    }
  }, onBack ? /*#__PURE__*/React.createElement(IconButton, {
    name: "chevron-left",
    label: "Back",
    onClick: onBack
  }) : null), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      textAlign: 'center',
      font: 'var(--type-subhead)',
      color: 'var(--text-primary)'
    }
  }, title), /*#__PURE__*/React.createElement("span", {
    style: {
      width: 44,
      display: 'flex',
      justifyContent: 'flex-end'
    }
  }, trailing));
}

/** The 393×852 device frame. Content fills it; screens own their own scrolling. */
function Phone({
  children,
  wash
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      width: 393,
      height: 852,
      position: 'relative',
      flex: '0 0 auto',
      borderRadius: 54,
      overflow: 'hidden',
      border: '1px solid var(--line-soft)',
      boxShadow: 'var(--shadow-lift)',
      display: 'flex',
      flexDirection: 'column',
      background: wash ? 'radial-gradient(120% 62% at 50% 14%, var(--accent-glow-faint) 0%, transparent 62%), var(--bg-base)' : 'var(--bg-base)'
    }
  }, children);
}

/** Grouped-list container used by Settings and History. */
function Group({
  title,
  children,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--space-3)',
      ...style
    }
  }, title ? /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-caption)',
      textTransform: 'uppercase',
      letterSpacing: '.08em',
      color: 'var(--text-tertiary)',
      padding: '0 var(--space-4)'
    }
  }, title) : null, /*#__PURE__*/React.createElement("div", {
    style: {
      background: 'var(--bg-raised)',
      border: '1px solid var(--line-hairline)',
      borderRadius: 'var(--radius-lg)',
      overflow: 'hidden',
      boxShadow: 'var(--shadow-row)'
    }
  }, children));
}
Object.assign(window, {
  Phone,
  StatusBar,
  HomeIndicator,
  NavBar,
  Group,
  Icon,
  IconButton,
  Wordmark,
  AppIcon
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/murmur-ios/Phone.jsx", error: String((e && e.message) || e) }); }

__ds_ns.AppIcon = __ds_scope.AppIcon;

__ds_ns.AppIconM = __ds_scope.AppIconM;

__ds_ns.Wordmark = __ds_scope.Wordmark;

__ds_ns.CaptureBloom = __ds_scope.CaptureBloom;

__ds_ns.SuccessBar = __ds_scope.SuccessBar;

__ds_ns.Transcript = __ds_scope.Transcript;

__ds_ns.Button = __ds_scope.Button;

__ds_ns.Icon = __ds_scope.Icon;

__ds_ns.IconButton = __ds_scope.IconButton;

__ds_ns.DestinationBadge = __ds_scope.DestinationBadge;

__ds_ns.EmptyState = __ds_scope.EmptyState;

__ds_ns.HistoryRow = __ds_scope.HistoryRow;

__ds_ns.PermissionRow = __ds_scope.PermissionRow;

__ds_ns.DestinationToggle = __ds_scope.DestinationToggle;

__ds_ns.EditableField = __ds_scope.EditableField;

__ds_ns.ToggleRow = __ds_scope.ToggleRow;

})();
