import { ISelectOption } from '@tylertech/forge';
import { FormOperationType } from '../types/FormOperationType';

export const FormOperations: FormOperationType[] = ['view', 'edit'];

export const FormOperationOptions: ISelectOption[] = FormOperations.map((operation) => ({
  value: operation,
  label: operation
}));
