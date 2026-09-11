import {
  booleanAttribute,
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
  InputSignal,
  InputSignalWithTransform,
  model,
  ModelSignal,
  Signal,
  signal,
  WritableSignal
} from '@angular/core';
import { ControlValueAccessor, NG_VALUE_ACCESSOR } from '@angular/forms';
import { CheckboxComponent, ISelectOption } from '@tylertech/forge';
import {
  ForgeCheckboxModule,
  ForgeCircularProgressModule,
  ForgeIconModule,
  ForgeLabelValueModule,
  ForgeSelectModule,
  ForgeSkeletonModule,
  ForgeTextFieldModule
} from '@tylertech/forge-angular';
import { FormInputType, FormOperationType, FormValueType } from '@tylertech/forge-vanguard-extended/shared';

/**
 * A single form field that renders itself as either a read-only `forge-label-value` or an editable control,
 * chosen by `valueMode`. One component therefore covers both halves of a view/edit page without the template
 * duplicating every field twice.
 *
 * It is a `ControlValueAccessor`, so it drops straight into a reactive form with `formControlName`. The value is
 * always carried as a string — including for checkboxes, which use the literals `'true'` and `'false'` — so a
 * whole form can be round-tripped through one control type regardless of how each field is presented.
 *
 * This is the field-level building block of the Edit page pattern. For a field that only ever displays, use
 * `forge-label-value` directly instead.
 */
@Component({
  selector: 'vanguard-dynamic-label-value',
  templateUrl: './dynamic-label-value.component.html',
  styleUrls: ['./dynamic-label-value.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    ForgeCheckboxModule,
    ForgeCircularProgressModule,
    ForgeIconModule,
    ForgeLabelValueModule,
    ForgeSelectModule,
    ForgeSkeletonModule,
    ForgeTextFieldModule
  ],
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: DynamicLabelValueComponent,
      multi: true
    }
  ]
})
export class DynamicLabelValueComponent implements ControlValueAccessor {
  /** Source of the per-instance input id. */
  private static _nextId = 0;

  /**
   * The field's label, used as the `forge-label-value` label in view mode and as the control's label in edit
   * mode.
   * @default 'Label'
   * @input
   */
  public readonly label: InputSignal<string> = input<string>('Label');

  /**
   * Whether the value is still being fetched. Renders a skeleton in place of the value, or a spinner beside a
   * checkbox's label.
   * @default false
   * @toggle
   * @input
   */
  public readonly loading: InputSignalWithTransform<boolean, unknown> = input<boolean, unknown>(false, {
    transform: booleanAttribute
  });

  /**
   * Whether to apply Forge's `error` theme to the editable control. Drive this from the bound control's
   * `invalid && touched` state; it has no effect in view mode.
   * @default false
   * @toggle
   * @input
   */
  public readonly error: InputSignalWithTransform<boolean, unknown> = input<boolean, unknown>(false, {
    transform: booleanAttribute
  });

  /**
   * Whether the editable control is disabled. Combined with the disabled state a reactive form sets through
   * `setDisabledState`, so either source disables the field.
   * @default false
   * @toggle
   * @input
   */
  public readonly disabled: InputSignalWithTransform<boolean, unknown> = input<boolean, unknown>(false, {
    transform: booleanAttribute
  });

  /**
   * Whether to render the view-mode value in a `<code>` element. Use for identifiers and other values a user
   * may need to compare character by character.
   * @default false
   * @toggle
   * @input
   */
  public readonly code: InputSignalWithTransform<boolean, unknown> = input<boolean, unknown>(false, {
    transform: booleanAttribute
  });

  /**
   * Whether to use Forge's dense sizing. Set this on every field of a field-heavy dialog.
   * @default false
   * @toggle
   * @input
   */
  public readonly dense: InputSignalWithTransform<boolean, unknown> = input<boolean, unknown>(false, {
    transform: booleanAttribute
  });

  /**
   * Whether to mark the editable control as required. This is presentation only — the bound control still needs
   * `Validators.required` for the form to actually enforce it.
   * @default false
   * @toggle
   * @input
   */
  public readonly required: InputSignalWithTransform<boolean, unknown> = input<boolean, unknown>(false, {
    transform: booleanAttribute
  });

  /**
   * Which control the field renders for its value.
   * @default 'text'
   * @enum 'text' | 'select' | 'checkbox'
   * @input
   */
  public readonly valueType: InputSignal<FormValueType> = input<FormValueType>('text');

  /**
   * The HTML `input[type]` used when `valueType` is `text`. Ignored for the other value types.
   * @default 'text'
   * @enum 'text' | 'number' | 'checkbox'
   * @input
   */
  public readonly inputType: InputSignal<FormInputType> = input<FormInputType>('text');

  /**
   * Whether the field displays its value or offers a control to change it.
   * @default 'view'
   * @enum 'view' | 'edit'
   * @input
   */
  public readonly valueMode: InputSignal<FormOperationType> = input<FormOperationType>('view');

  /**
   * The options offered when `valueType` is `select`. In view mode the matching option's `label` is shown, so
   * these must be supplied for a select field to read correctly even when it is not editable.
   * @default []
   * @input
   */
  public readonly selectOptions: InputSignal<ISelectOption[]> = input<ISelectOption[]>([]);

  /**
   * The field's value, always as a string. Checkboxes use `'true'` and `'false'`; selects use the option's
   * `value` coerced to a string.
   * @default 'Value'
   * @input
   */
  public readonly value: ModelSignal<string> = model<string>('Value');

  /** Disabled state pushed in by a reactive form, kept separate from the `disabled` input. */
  protected readonly _formDisabled: WritableSignal<boolean> = signal<boolean>(false);

  /** Whether the control is disabled from either source. */
  protected readonly _isDisabled: Signal<boolean> = computed(() => this.disabled() || this._formDisabled());

  /** Whether a checkbox field is checked, derived from the string value. */
  protected readonly _isChecked: Signal<boolean> = computed(() => this.value() === 'true');

  /** The value handed to the underlying Forge control, translated for checkboxes. */
  protected readonly _formValue: Signal<string> = computed(() => {
    if (this.valueType() === 'checkbox') {
      return this._isChecked() ? 'on' : 'off';
    }
    return this.value();
  });

  /** The label of the currently selected option, for rendering a select field in view mode. */
  protected readonly _selectValue: Signal<string> = computed(
    () => this.selectOptions().find((option) => option.value === this.value())?.label ?? ''
  );

  /** Whether the view-mode value is empty and should reserve its line without showing anything. */
  protected readonly _isEmpty: Signal<boolean> = computed(() => {
    const value = this.value();
    return value === null || value === undefined || value === '';
  });

  /**
   * Per-instance id for the editable text input, so its `<label for>` still resolves when several fields are
   * rendered on the same page.
   */
  protected readonly _inputId: string = `vanguard-dynamic-label-value-${DynamicLabelValueComponent._nextId++}`;

  private _onChangeFn: (value: string) => void = () => undefined;

  private _onTouchedFn: () => void = () => undefined;

  public writeValue(value: string): void {
    this.value.set(value);
  }

  public registerOnChange(fn: (value: string) => void): void {
    this._onChangeFn = fn;
  }

  public registerOnTouched(fn: () => void): void {
    this._onTouchedFn = fn;
  }

  public setDisabledState(state: boolean): void {
    this._formDisabled.set(state);
  }

  protected _onInput(event: Event): void {
    this._commit((event.target as HTMLInputElement).value);
  }

  protected _onSelect(event: CustomEvent<string>): void {
    this._commit(event.detail);
  }

  protected _onCheckboxChange(event: Event): void {
    this._commit((event.target as CheckboxComponent).checked ? 'true' : 'false');
  }

  /** Publishes a new value to both the model signal and the bound reactive form control. */
  private _commit(value: string): void {
    this.value.set(value);
    this._onChangeFn(value);
    this._onTouchedFn();
  }
}
