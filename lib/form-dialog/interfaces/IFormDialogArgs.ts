import { DialogOperationType } from '@tylertech/forge-vanguard-extended/shared';

/**
 * Every input of `FormDialogComponent` as a plain object, for driving the Storybook controls and the component's
 * own configurable demo.
 */
export interface IFormDialogArgs {
  operation: DialogOperationType;
  entityLabel: string;
  heading: string;
  icon: string;
  confirmDisabled: boolean;
  busy: boolean;
  confirmLabel: string;
  cancelLabel: string;
  confirmIcon: string;
  cancelIcon: string;
}

/** The component's own defaults, so a demo can highlight which inputs have been changed. */
export const FormDialogArgsDefault: IFormDialogArgs = {
  operation: 'edit',
  entityLabel: '',
  heading: '',
  icon: 'edit',
  confirmDisabled: false,
  busy: false,
  confirmLabel: 'Confirm',
  cancelLabel: 'Cancel',
  confirmIcon: 'check',
  cancelIcon: 'close'
};
