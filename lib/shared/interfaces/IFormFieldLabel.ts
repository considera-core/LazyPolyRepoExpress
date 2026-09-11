/**
 * Maps a form control's path to the human-readable label used in error messages.
 *
 * Without a mapping, error text falls back to the raw control path (`address.zip`), which is rarely what a
 * user should read. Pass a collection of these to anything that renders validation messages.
 */
export interface IFormFieldLabel {
  /** The control's path within its form group, e.g. `zip` or `address.zip`. */
  key: string;

  /** The label to show in place of `key`, e.g. `Postal code`. */
  label: string;
}
