export interface IconProps {
  /** File stem of an SVG in assets/icons (Lucide set), e.g. "bell", "calendar". */
  name: string;
  /** Rendered box in px. 20 for inline, 24 for row leading, 28+ for hero. */
  size?: number;
  /** Shrinks the glyph inside its box (0.85 reads lighter next to light text). */
  strokeScale?: number;
  /** Accessible label. Omit for decorative icons — the span is then aria-hidden. */
  title?: string;
  style?: React.CSSProperties;
}
