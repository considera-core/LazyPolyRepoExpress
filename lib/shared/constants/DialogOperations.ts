import { ISelectOption } from '@tylertech/forge';
import { DialogOperationType } from '../types/DialogOperationType';

export const DialogOperations: DialogOperationType[] = ['view', 'add', 'edit'];

export const DialogOperationOptions: ISelectOption[] = DialogOperations.map((operation) => ({
  value: operation,
  label: operation
}));
