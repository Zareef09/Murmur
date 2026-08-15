export interface EmptyStateProps {
  /** Icon name from assets/icons. Defaults to "audio-lines". */
  icon?: string;
  /** One warm line: "Nothing captured yet". */
  title: string;
  /** One supporting line, max ~2 lines at large Dynamic Type. */
  body?: string;
  /** Optional node — usually a single Button. */
  action?: React.ReactNode;
  style?: React.CSSProperties;
}
