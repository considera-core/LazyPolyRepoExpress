import { ISelectOption } from '@tylertech/forge';
import { FormInputType, FormOperationType, FormValueType } from '@tylertech/forge-vanguard-extended/shared';

/**
 * Every input of `DynamicLabelValueComponent` as a plain object, for driving the Storybook controls and the
 * component's own configurable demo.
 */
export interface IDynamicLabelValueArgs {
  label: string;
  loading: boolean;
  error: boolean;
  disabled: boolean;
  code: boolean;
  dense: boolean;
  required: boolean;
  valueType: FormValueType;
  inputType: FormInputType;
  valueMode: FormOperationType;
  selectOptions: ISelectOption[];
  value: string;
}

/** The component's own defaults, so a demo can highlight which inputs have been changed. */
export const DynamicLabelValueArgsDefault: IDynamicLabelValueArgs = {
  label: 'Label',
  loading: false,
  error: false,
  disabled: false,
  code: false,
  dense: false,
  required: false,
  valueType: 'text',
  inputType: 'text',
  valueMode: 'view',
  selectOptions: [],
  value: 'Value'
};
