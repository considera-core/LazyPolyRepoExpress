import { ISelectOption } from '@tylertech/forge';
import { FormInputType } from '../types/FormInputType';

export const FormInputTypes: FormInputType[] = ['text', 'number', 'checkbox'];

export const FormInputTypeOptions: ISelectOption[] = FormInputTypes.map((inputType) => ({
  value: inputType,
  label: inputType
}));
