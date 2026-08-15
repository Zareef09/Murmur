/**
 * @startingPoint section="Capture" subtitle="The signature light-well in all four states" viewport="700x300"
 */
export interface CaptureBloomProps {
  /** The four states of capture. One element morphs between them — never cut to a new screen. */
  state?: 'idle' | 'listening' | 'thinking' | 'done';
  /** Normalised mic amplitude 0–1. Smooth it before passing (≈120ms attack, ≈400ms release). */
  level?: number;
  /** Diameter in px. 240 on the capture screen, 120 in the confirmation header. */
  size?: number;
  /** Tap handler — starts or stops listening. */
  onTap?: () => void;
  /** Quiet caption under the well ("Tap to speak"). Doubles as the aria-label. */
  label?: string;
  style?: React.CSSProperties;
}
