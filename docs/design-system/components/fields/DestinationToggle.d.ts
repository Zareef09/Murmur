export interface DestinationToggleProps {
  value?: 'reminder' | 'event';
  onChange?: (value: 'reminder' | 'event') => void;
  /** sm inside a field row, md standing alone. */
  size?: 'sm' | 'md';
  style?: React.CSSProperties;
}
