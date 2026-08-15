export interface DestinationBadgeProps {
  destination?: 'reminder' | 'event';
  /** chip = tinted pill with label; glyph = 38px rounded square for list rows; quiet = label + icon, no fill. */
  variant?: 'chip' | 'glyph' | 'quiet';
  style?: React.CSSProperties;
}
