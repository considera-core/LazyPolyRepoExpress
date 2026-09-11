import { ISelectOption } from '@tylertech/forge';
import { FormValueType } from '../types/FormValueType';

export const FormValueTypes: FormValueType[] = ['text', 'select', 'checkbox'];

export const FormValueTypeOptions: ISelectOption[] = FormValueTypes.map((valueType) => ({
  value: valueType,
  label: valueType
}));
