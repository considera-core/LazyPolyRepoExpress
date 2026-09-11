import { ISelectOption } from '@tylertech/forge';
import { DynamicIconButtonTooltipPlacements } from './DynamicIconButtonTooltipPlacements';

export const DynamicIconButtonTooltipPlacementOptions: ISelectOption[] = DynamicIconButtonTooltipPlacements.map(
  (placement) => ({
    value: placement,
    label: placement
  })
);
