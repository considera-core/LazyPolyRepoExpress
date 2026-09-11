import { ISelectOption } from '@tylertech/forge';
import { DynamicIconButtonThemes } from './DynamicIconButtonThemes';

export const DynamicIconButtonThemeOptions: ISelectOption[] = DynamicIconButtonThemes.map((theme) => ({
  value: theme,
  label: theme
}));
