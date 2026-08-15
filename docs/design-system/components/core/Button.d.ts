/**
 * @startingPoint section="Core" subtitle="Primary, secondary and ghost actions" viewport="700x220"
 */
export interface ButtonProps {
  /** primary = the one confident action; secondary = hairline alternative; ghost = quiet text action (Cancel, Undo). */
  variant?: 'primary' | 'secondary' | 'ghost';
  /** lg (60px) is the default on capture and confirmation screens; sm only inside rows. */
  size?: 'sm' | 'md' | 'lg';
  /** Icon name from assets/icons, rendered before the label. */
  icon?: string;
  /** Icon name rendered after the label. */
  iconAfter?: string;
  fullWidth?: boolean;
  disabled?: boolean;
  onClick?: () => void;
  children?: React.ReactNode;
  style?: React.CSSProperties;
}
