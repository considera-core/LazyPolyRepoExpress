import { ISelectOption } from '@tylertech/forge';
import { DynamicIconButtonDensities } from './DynamicIconButtonDensities';

export const DynamicIconButtonDensityOptions: ISelectOption[] = DynamicIconButtonDensities.map((density) => ({
  value: density,
  label: density
}));
