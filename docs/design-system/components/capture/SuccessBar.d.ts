export interface SuccessBarProps {
  /** What happened, in the app's voice: "Saved to Reminders · tomorrow 5:00 PM". */
  message?: string;
  /** Chooses the leading glyph and its tint. */
  destination?: 'reminder' | 'event';
  /** Omit to render a bare confirmation with no Undo. */
  onUndo?: () => void;
  style?: React.CSSProperties;
}
