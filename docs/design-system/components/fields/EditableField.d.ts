/**
 * @startingPoint section="Fields" subtitle="Tap-to-edit parsed values" viewport="700x260"
 */
export interface EditableFieldProps {
  /** Small uppercase caption — "TITLE", "WHEN", "GOES TO". */
  label?: string;
  /** Current value. Empty renders `placeholder` in tertiary ("No date"). */
  value?: string;
  placeholder?: string;
  /** Leading icon name from assets/icons. */
  icon?: string;
  /** Editing lifts the field to a raised surface with an ember hairline. */
  editing?: boolean;
  /** Renders the value one contrast step back (used for derived values). */
  muted?: boolean;
  onPress?: () => void;
  onChange?: (value: string) => void;
  /** Custom editor shown while editing instead of the text input (date picker, toggle). */
  children?: React.ReactNode;
  style?: React.CSSProperties;
}
