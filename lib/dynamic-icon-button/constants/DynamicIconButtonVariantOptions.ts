import { ISelectOption } from '@tylertech/forge';
import { DynamicIconButtonVariants } from './DynamicIconButtonVariants';

export const DynamicIconButtonVariantOptions: ISelectOption[] = DynamicIconButtonVariants.map((variant) => ({
  value: variant,
  label: variant
}));
