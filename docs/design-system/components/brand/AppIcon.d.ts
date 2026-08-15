export interface AppIconProps {
  /** Rendered size in px. Verified legible down to 40px. */
  size?: number;
  /** Home-screen variant: light ground or warm near-black ground. */
  theme?: 'light' | 'dark';
  style?: React.CSSProperties;
}
