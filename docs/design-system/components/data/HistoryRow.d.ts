/**
 * @startingPoint section="Lists" subtitle="A past capture, with swipe-to-delete" viewport="700x240"
 */
export interface HistoryRowProps {
  /** The captured task, verbatim as parsed. */
  title: string;
  destination?: 'reminder' | 'event';
  /** Absolute date/time, or omit for a no-date capture. */
  when?: string;
  /** Soft relative timestamp: "2h ago", "Yesterday". */
  relative?: string;
  /** Reveals the delete action. */
  swiped?: boolean;
  divider?: boolean;
  /** Opens the item in Reminders or Calendar. */
  onPress?: () => void;
  /** Called when the row is swiped or the swipe is dismissed. */
  onSwipe?: () => void;
  onDelete?: () => void;
  style?: React.CSSProperties;
}
