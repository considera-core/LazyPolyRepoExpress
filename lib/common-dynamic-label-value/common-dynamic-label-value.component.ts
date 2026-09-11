import { booleanAttribute, ChangeDetectionStrategy, Component, computed, input, InputSignal, InputSignalWithTransform, model, ModelSignal, Signal, signal, WritableSignal } from '@angular/core';
import { ForgeCheckboxModule, ForgeCircularProgressModule, ForgeIconModule, ForgeLabelValueModule, ForgeSelectModule, ForgeSkeletonModule, ForgeTextFieldModule } from '@tylertech/forge-angular';
import { ControlValueAccessor, FormsModule, NG_VALUE_ACCESSOR, ReactiveFormsModule } from '@angular/forms';
import { CheckboxComponent, IconRegistry, ISelectOption } from '@tylertech/forge';
import { tylIconAttachMoney } from '@tylertech/tyler-icons';

/**
 * Temporary copy from forge-vanguard-extended until lib is published
 */
@Component({
  selector: 'tyl-common-dynamic-label-value',
  templateUrl: './common-dynamic-label-value.component.html',
  styleUrl: './common-dynamic-label-value.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    ForgeLabelValueModule,
    ForgeSkeletonModule,
    ForgeTextFieldModule,
    FormsModule,
    ReactiveFormsModule,
    ForgeSelectModule,
    ForgeCheckboxModule,
    ForgeCircularProgressModule,
    ForgeIconModule,
  ],
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: CommonDynamicLabelValueComponent,
      multi: true
    }
  ]
})
export class CommonDynamicLabelValueComponent implements ControlValueAccessor {
  public readonly FormValueTypeEnum = FormValueTypeEnum;

  public readonly FormValueOperationEnum = FormValueOperationEnum;

  public readonly FormInputTypeEnum = FormInputTypeEnum;

  public readonly label: InputSignal<string> = input<string>('');

  /**
   *
   */
  public readonly density: InputSignal<FormValueDensityEnum> = input<FormValueDensityEnum>(FormValueDensityEnum.Default);

  public readonly loading: InputSignal<boolean> = input<boolean>(false);

  public readonly invalid: InputSignal<boolean> = input<boolean>(false);

  /**
   * <b>NOTE: Only use if this component is not being used in a form. If this component is being used in a form, use the form control's disabled state instead.
   */
  public readonly disabled: InputSignalWithTransform<boolean, unknown> = input<boolean, unknown>(false, { transform: booleanAttribute });

  public readonly showEmpty: InputSignalWithTransform<boolean, unknown> = input<boolean, unknown>(false, { transform: booleanAttribute });

  public readonly code: InputSignalWithTransform<boolean, unknown> = input<boolean, unknown>(false, { transform: booleanAttribute });

  /**
   * <b>NOTE: Overrides `density`.
   */
  public readonly dense: InputSignalWithTransform<boolean, unknown> = input<boolean, unknown>(false, { transform: booleanAttribute });

  /**
   * Shows a red asterisk indicating that the field is required. Only shows in edit value mode.
   */
  public readonly required: InputSignalWithTransform<boolean, unknown> = input<boolean, unknown>(false, { transform: booleanAttribute });

  public readonly hideLabel: InputSignalWithTransform<boolean, unknown> = input<boolean, unknown>(false, { transform: booleanAttribute });

  public readonly valueType: InputSignal<FormValueTypeEnum> = input<FormValueTypeEnum>(FormValueTypeEnum.Text);

  /**
   * Controls the HTML input type of the text field.
   * Required if valueType is Text.
   */
  public readonly inputType: InputSignal<FormInputTypeEnum> = input<FormInputTypeEnum>(FormInputTypeEnum.String);

  /**
   * Forces numeric values to render with this many decimal places in view mode (ex: `3` renders 1233.2 as 1,233.200).
   * When left undefined, the decimal places of the provided value are preserved as-is.
   */
  public readonly decimalPlaces: InputSignal<number | undefined> = input<number | undefined>(undefined);

  public readonly valueMode: InputSignal<FormValueOperationEnum> = input<FormValueOperationEnum>(FormValueOperationEnum.View);

  public readonly selectOptions: InputSignal<ISelectOption[]> = input<ISelectOption[]>([]);

  public readonly value: ModelSignal<string> = model<string>('Value');

  private _onChangeFn: (value: string) => void = (value: string) => {};

  private _onTouchedFn: () => void = () => {};

  protected readonly _formDisabled: WritableSignal<boolean> = signal<boolean>(false);

  protected readonly _isDisabled: Signal<boolean> = computed(() => this.disabled() || this._formDisabled());

  protected readonly _formValue: Signal<string> = computed(() => {
    switch (this.valueType()) {
      case FormValueTypeEnum.Checkbox:
        return this.value() === 'true' ? 'on' : 'off';
      default:
        return this.value();
    }
  });

  protected readonly _selectValue: Signal<string> = computed(() => this.selectOptions().find(x => x.value === this.value())?.label ?? '');

  /**
   * The value rendered in view mode. Numeric input types are formatted with thousands separators (ex: 1,233.23).
   */
  protected readonly _displayValue: Signal<string> = computed(() => {
    const value = this.valueType() === FormValueTypeEnum.Select ? this._selectValue() : this.value();

    if (this.decimalPlaces() !== undefined) {
      return this._groupNumber(value);
    }

    switch (this.inputType()) {
      case FormInputTypeEnum.Number:
      case FormInputTypeEnum.Currency:
        return this._groupNumber(value);
      default:
        return `${value}`;
    }
  });

  protected readonly _defaultDensity: Signal<boolean> = computed(() => this.density() === 'default' && !this.dense());

  protected readonly _isEmptyNow: Signal<boolean> = computed(() => this.value() === null || this.value() === undefined || this.value() === '');

  protected readonly _labelPosition: Signal<'inset' | 'inline-start' | 'none'> = computed(() => {
    if (this.required()) {
      if (this.dense() || this.density() !== 'default') {
        return 'inline-start';
      }
      return 'inset';
    }

    if (!this.label()) {
      return 'none';
    }
    return 'inset';
  });

  protected readonly _labelAlignment: Signal<'default' | 'baseline'> = computed(() => {
    if (this._labelPosition() === 'inline-start') {
      return 'baseline';
    }
    return 'default';
  });

  public writeValue(value: string): void {
    this.value.set(value);
  }

  public registerOnChange(fn: (value: string) => void): void {
    this._onChangeFn = fn;
  }

  public registerOnTouched(fn: () => void): void {
    this._onTouchedFn = fn;
  }

  public setDisabledState?(state: boolean): void {
    this._formDisabled.set(state);
  }

  protected _onChange(event: Event): void {
    const inputElement = event.target as HTMLInputElement;
    this.value.set(inputElement.value);
    this._onChangeFn(inputElement.value);
    this._onTouchedFn();
  }

  protected _onSelect(event: CustomEvent<string>): void {
    this.value.set(event.detail);
    this._onChangeFn(event.detail);
    this._onTouchedFn();
  }

  /**
   * Adds thousands separators, using `decimalPlaces` when provided and otherwise preserving the
   * decimal places of the original value. Non-numeric values are returned untouched.
   */
  private _groupNumber(value: string): string {
    const stringValue = `${value}`;
    const trimmedValue = stringValue.trim();
    const numericValue = Number(trimmedValue);

    if (trimmedValue === '' || Number.isNaN(numericValue)) {
      return stringValue;
    }

    const fractionDigits = this.decimalPlaces() ?? trimmedValue.split('.')[1]?.length ?? 0;
    return numericValue.toLocaleString('en-US', { minimumFractionDigits: fractionDigits, maximumFractionDigits: fractionDigits });
  }

  protected _onCheckboxChange(event: Event): void {
    const checkbox = event.target as CheckboxComponent;
    this.value.set(checkbox.checked ? 'true' : 'false');
    this._onChangeFn(checkbox.checked ? 'true' : 'false');
    this._onTouchedFn();
  }

  static {
    IconRegistry.define([
      tylIconAttachMoney
    ]);
  }
}
export enum FormValueOperationEnum {
  View,
  Edit,
}
export enum FormInputTypeEnum {
  String = 'text',
  Number = 'number',
  Currency = 'currency',
  Boolean = 'checkbox',
}
export enum FormValueTypeEnum {
  Text = 0,
  Select = 1,
  Checkbox = 2,
}
export enum FormValueDensityEnum {
  Small = 'small',
  Medium = 'medium',
  Default = 'default',
}
