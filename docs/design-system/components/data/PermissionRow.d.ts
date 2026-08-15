export interface PermissionRowProps {
  /** What is being asked for, in the user's words: "Microphone", "Reminders", "Calendar". */
  label: string;
  status?: 'granted' | 'needed';
  /** Overrides the default sub-line. */
  hint?: string;
  /** Shown only when status is "needed". */
  onFix?: () => void;
  divider?: boolean;
  style?: React.CSSProperties;
}
