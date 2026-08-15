export interface TranscriptProps {
  /** Words the recogniser has committed. */
  text?: string;
  /** The in-flight tail, rendered one contrast step back. */
  partial?: string;
  /** Shown when both are empty ("I'm listening…"). */
  placeholder?: string;
  align?: 'center' | 'left';
  style?: React.CSSProperties;
}
