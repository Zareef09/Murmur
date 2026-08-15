/**
 * @startingPoint section="Brand" subtitle="Wordmark and app icon" viewport="700x200"
 */
export interface WordmarkProps {
  /** Cap height in px. 28 is the standard lockup; never below 18. */
  size?: number;
  /** inverse for dark photography or the ember fill; accent only on cream. */
  tone?: 'primary' | 'inverse' | 'accent';
  /** The ember dot. Drop it only when the mark sits beside the app icon. */
  dot?: boolean;
  style?: React.CSSProperties;
}
