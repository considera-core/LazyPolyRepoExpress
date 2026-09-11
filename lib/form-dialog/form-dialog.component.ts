import {
  booleanAttribute,
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
  InputSignal,
  InputSignalWithTransform,
  output,
  OutputEmitterRef,
  Signal
} from '@angular/core';
import { IconRegistry } from '@tylertech/forge';
import {
  ForgeButtonModule,
  ForgeIconButtonModule,
  ForgeIconModule,
  ForgeScaffoldModule,
  ForgeToolbarModule
} from '@tylertech/forge-angular';
import { tylIconCheck, tylIconClose, tylIconEdit } from '@tylertech/tyler-icons';
import { DialogOperationType } from '@tylertech/forge-vanguard-extended/shared';

/**
 * The chrome of a modify dialog: a titled header with a close button, a body that takes the consumer's form, and
 * an inverted footer holding cancel and confirm.
 *
 * This is the shell behind the Edit dialog pattern — used by both the Nested Single-Instance case (opened from a
 * card's header edit button) and the Complex/Busy Multi-Instance case (opened from a table row action). It is
 * deliberately presentational: it holds no `DialogRef`, performs no saving, and never touches the projected
 * form. The dialog component that hosts it owns `DialogRef`, validation and persistence, and reacts to
 * {@link confirm} and {@link cancel}.
 *
 * ```html
 * <vanguard-form-dialog
 *   operation="edit"
 *   entityLabel="User"
 *   [confirmDisabled]="!_form.dirty"
 *   [busy]="_saving()"
 *   (confirm)="_save()"
 *   (cancel)="_close()">
 *   <form [formGroup]="_form">
 *     <!-- the consuming app's own fields -->
 *   </form>
 * </vanguard-form-dialog>
 * ```
 *
 * Open it persistently (`options: { persistent: true }`) so a stray backdrop click cannot discard a part-filled
 * form.
 */
@Component({
  selector: 'vanguard-form-dialog',
  templateUrl: './form-dialog.component.html',
  styleUrls: ['./form-dialog.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ForgeButtonModule, ForgeIconButtonModule, ForgeIconModule, ForgeScaffoldModule, ForgeToolbarModule]
})
export class FormDialogComponent {
  static {
    // Only the shell's own default icons. A consumer overriding `icon`, `confirmIcon` or `cancelIcon` must
    // register that icon itself.
    IconRegistry.define([tylIconCheck, tylIconClose, tylIconEdit]);
  }

  /**
   * Which operation the dialog was opened to perform. Supplies the heading's verb, and hides the confirm button
   * entirely for `view`.
   * @default 'edit'
   * @enum 'view' | 'add' | 'edit'
   * @input
   */
  public readonly operation: InputSignal<DialogOperationType> = input<DialogOperationType>('edit');

  /**
   * The singular name of the thing being modified, e.g. `User` or `Party`. Combined with the operation's verb to
   * form the default heading.
   * @default ''
   * @input
   */
  public readonly entityLabel: InputSignal<string> = input<string>('');

  /**
   * Overrides the whole heading. Set this when `<verb> <entityLabel>` does not read well; otherwise leave it and
   * pass `entityLabel`.
   * @default ''
   * @input
   */
  public readonly heading: InputSignal<string> = input<string>('');

  /**
   * Name of the Forge icon shown before the heading. Pass an empty string for no icon.
   * @default 'edit'
   * @input
   * @see {@link https://tylerforge.design/assets/icon-library/ Forge Icon Library}
   */
  public readonly icon: InputSignal<string> = input<string>('edit');

  /**
   * Whether the confirm action is unavailable. The Edit dialog pattern passes `!form.dirty`, so confirm only
   * lights up once something has actually changed.
   * @default false
   * @toggle
   * @input
   */
  public readonly confirmDisabled: InputSignalWithTransform<boolean, unknown> = input<boolean, unknown>(false, {
    transform: booleanAttribute
  });

  /**
   * Whether a save is in flight. Disables every action so the dialog cannot be confirmed twice or dismissed
   * mid-request.
   * @default false
   * @toggle
   * @input
   */
  public readonly busy: InputSignalWithTransform<boolean, unknown> = input<boolean, unknown>(false, {
    transform: booleanAttribute
  });

  /**
   * Label for the confirm button. Already-localized text.
   * @default 'Confirm'
   * @input
   */
  public readonly confirmLabel: InputSignal<string> = input<string>('Confirm');

  /**
   * Label for the cancel button, also the accessible name of the header's close button. Already-localized text.
   * @default 'Cancel'
   * @input
   */
  public readonly cancelLabel: InputSignal<string> = input<string>('Cancel');

  /**
   * Name of the Forge icon on the confirm button.
   * @default 'check'
   * @input
   */
  public readonly confirmIcon: InputSignal<string> = input<string>('check');

  /**
   * Name of the Forge icon on the cancel and close buttons.
   * @default 'close'
   * @input
   */
  public readonly cancelIcon: InputSignal<string> = input<string>('close');

  /**
   * Emitted when the confirm button is pressed. The host is responsible for validating the form and closing the
   * dialog — the shell does neither.
   * @output
   */
  public readonly confirm: OutputEmitterRef<void> = output<void>();

  /**
   * Emitted when either the footer's cancel button or the header's close button is pressed.
   * @output
   */
  // `cancel` shadows a native DOM event name, which the rule flags because a bubbling native `cancel` would also
  // reach a host binding. Nothing this shell renders fires one, and the name matches the vanguard-common API this
  // component replaces, so keep it rather than inventing a synonym.
  // eslint-disable-next-line @angular-eslint/no-output-native
  public readonly cancel: OutputEmitterRef<void> = output<void>();

  /** The heading actually rendered, after applying the `heading` override. */
  protected readonly _resolvedHeading: Signal<string> = computed(
    () => this.heading() || `${this._operationVerb()} ${this.entityLabel()}`.trim()
  );

  /** Whether to offer a confirm action at all — a `view` dialog is read-only. */
  protected readonly _showConfirm: Signal<boolean> = computed(() => this.operation() !== 'view');

  /** The verb naming the operation, for the default heading. */
  private readonly _operationVerb: Signal<string> = computed(() => {
    switch (this.operation()) {
      case 'add':
        return 'Add';
      case 'view':
        return 'View';
      default:
        return 'Edit';
    }
  });
}
