export interface IconButtonProps {
  /** Icon name from assets/icons. */
  name: string;
  /** Required accessible label — these buttons never carry visible text. */
  label: string;
  /** Full hit box in px. Never below 44. */
  size?: number;
  /** quiet = bare on the background; surface = raised chip over content; accent = ember fill. */
  tone?: 'quiet' | 'surface' | 'accent';
  onClick?: () => void;
  style?: React.CSSProperties;
}
