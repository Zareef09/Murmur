/**
 * @startingPoint section="Brand" subtitle="App logo — the letter M" viewport="700x260"
 */
export interface AppIconMProps {
  /** Rendered size in px. Verified legible down to 32px. */
  size?: number;
  /** Only 'dark' is used app-wide: warm near-black ground, cream ink M. */
  theme?: 'light' | 'dark';
  style?: React.CSSProperties;
}
