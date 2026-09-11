import {
  DynamicIconButtonDensityType,
  DynamicIconButtonThemeType,
  DynamicIconButtonTooltipPlacementType,
  DynamicIconButtonVariantType
} from '../types';

export interface IDynamicIconButtonArgs {
  icon: string;
  activeIcon: string;
  isActive: boolean;
  isLoading: boolean;
  isDisabled: boolean;
  isExternal: boolean;
  density: DynamicIconButtonDensityType;
  theme: DynamicIconButtonThemeType;
  variant: DynamicIconButtonVariantType;
  activeVariant: DynamicIconButtonVariantType;
  tooltipPlacement: DynamicIconButtonTooltipPlacementType;
  description: string;
  activeDescription: string;
  disabledDescription: string;
  tooltipDelay: number;
}

export const DynamicIconButtonArgsDefault: IDynamicIconButtonArgs = {
  icon: '',
  activeIcon: '',
  isActive: false,
  isLoading: false,
  isDisabled: false,
  isExternal: false,
  density: 'large',
  theme: 'default',
  variant: 'icon',
  activeVariant: 'raised',
  tooltipPlacement: 'left',
  description: '',
  activeDescription: '',
  disabledDescription: '',
  tooltipDelay: 300
};
