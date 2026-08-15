export interface ToggleRowProps {
  /** The preference, phrased as a plain statement: "Always confirm before saving". */
  label: string;
  /** One quiet line of why, not how. */
  description?: string;
  checked?: boolean;
  onChange?: (checked: boolean) => void;
  /** Hairline under the row; false on the last row of a group. */
  divider?: boolean;
  style?: React.CSSProperties;
}
