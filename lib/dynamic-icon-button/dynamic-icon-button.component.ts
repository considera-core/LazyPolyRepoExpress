import {
  booleanAttribute,
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
  InputSignal,
  numberAttribute,
  Signal
} from '@angular/core';
import type { IconButtonVariant } from '@tylertech/forge';
import {
  ForgeCircularProgressModule,
  ForgeIconButtonModule,
  ForgeIconModule,
  ForgeTooltipModule
} from '@tylertech/forge-angular';
import { DynamicIconButtonVariantType } from './types/DynamicIconButtonVariantType';
import { DynamicIconButtonDensityType } from './types/DynamicIconButtonDensityType';
import { DynamicIconButtonThemeType } from './types/DynamicIconButtonThemeType';
import { DynamicIconButtonTooltipPlacementType } from './types/DynamicIconButtonTooltipPlacementType';

/**
 * A Forge icon button that changes appearance with its own state: it swaps in a second icon and variant while
 * active, replaces the icon with a progress spinner while loading, and shows a tooltip whose text follows the
 * same state changes.
 *
 * Use it for toggles and for actions that take long enough to need a busy indicator. For a plain, single-state
 * action, use `forge-icon-button` directly instead.
 *
 * The icons passed to `icon` and `activeIcon` must already be registered with Forge's `IconRegistry`.
 * `description` is not optional in practice — it is the button's accessible name as well as its tooltip text.
 */
@Component({
  selector: 'vanguard-dynamic-icon-button',
  templateUrl: './dynamic-icon-button.component.html',
  styleUrls: ['./dynamic-icon-button.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ForgeIconButtonModule, ForgeIconModule, ForgeTooltipModule, ForgeCircularProgressModule]
})
export class DynamicIconButtonComponent {
  /**
   * Name of the Forge Icon shown in the default state. This will be the fall back icon when `activeIcon` is not provided.
   * @required
   * @input
   * @see {@link https://tylerforge.design/assets/icon-library/ Forge Icon Library}
   */
  public readonly icon: InputSignal<string> = input.required<string>();

  /**
   * Name of the Forge Icon shown in the active state. Falls back to `icon` when empty.
   * @default ''
   * @input
   * @see {@link https://tylerforge.design/assets/icon-library/ Forge Icon Library}
   */
  public readonly activeIcon: Signal<string> = input<string>('');

  /**
   * Whether the button is in its active state, which controls the active icon and variant.
   * @default false
   * @toggle
   * @input
   */
  public readonly isActive: Signal<boolean> = input<boolean, unknown>(false, { transform: booleanAttribute });

  /**
   * Whether to replace the icon with a circular progress. Set this while the button's action is in-flight.
   * @default false
   * @toggle
   * @input
   */
  public readonly isLoading: Signal<boolean> = input<boolean, unknown>(false, { transform: booleanAttribute });

  /**
   * Whether the button is disabled. Pair this with `disabledDescription` to explain why.
   * @default false
   * @toggle
   * @input
   */
  public readonly isDisabled: Signal<boolean> = input<boolean, unknown>(false, { transform: booleanAttribute });

  /**
   * Whether the button opens an external link. Typically used in conjunction with `href`.
   * @default false
   * @toggle
   * @input
   */
  public readonly isExternal: Signal<boolean> = input<boolean, unknown>(false, { transform: booleanAttribute });

  /**
   * The Forge density, controlling the button's overall size. Defaults to `large`.
   * @default 'large'
   * @enum 'small' | 'medium' | 'large'
   * @input
   */
  public readonly density: Signal<DynamicIconButtonDensityType> = input<DynamicIconButtonDensityType>('large');

  /**
   * The Forge theme applied to the icon and background. Defaults to `default` via the defaults token.
   * Note this is a Forge theme name — destructive actions use `error`.
   * @default 'default'
   * @enum 'default' | 'primary' | 'success' | 'warning' | 'error'
   * @input
   */
  public readonly theme: Signal<DynamicIconButtonThemeType> = input<DynamicIconButtonThemeType>('default');

  /**
   * The Forge icon button variant used in the resting state.
   * @default 'icon'
   * @enum 'icon' | 'outlined' | 'tonal' | 'filled' | 'raised'
   * @input
   */
  public readonly variant: Signal<DynamicIconButtonVariantType> = input<DynamicIconButtonVariantType>('icon');

  /**
   * The Forge icon button variant used while `active` is true, to make the active state obvious.
   * @default 'raised'
   * @enum 'icon' | 'outlined' | 'tonal' | 'filled' | 'raised'
   * @input
   */
  public readonly activeVariant: Signal<DynamicIconButtonVariantType> = input<DynamicIconButtonVariantType>('raised');

  /**
   * Where the tooltip is placed relative to the button.
   * @default 'left'
   * @enum 'top' | 'bottom' | 'left' | 'right'
   * @input
   * @todo Potential default constant to provide
   */
  public readonly tooltipPlacement: Signal<DynamicIconButtonTooltipPlacementType> =
    input<DynamicIconButtonTooltipPlacementType>('left');

  /**
   * Tooltip text and accessible name for the resting state. Required for the button to be accessible.
   * @default ''
   * @input
   */
  public readonly description: Signal<string> = input<string>('');

  /**
   * Tooltip text and accessible name while `active` is true. Falls back to `description` when empty.
   * @default ''
   * @input
   */
  public readonly activeDescription: Signal<string> = input<string>('');

  /**
   * Tooltip text and accessible name while `disabled` is true — usually an explanation of why the action is
   * unavailable. Falls back to `description` when empty.
   * @default ''
   * @input
   */
  public readonly disabledDescription: Signal<string> = input<string>('');

  /**
   * How long, in milliseconds, the pointer must rest on the button before the tooltip appears.
   * @default 300
   * @input
   */
  public readonly tooltipDelay: Signal<number> = input(300, { transform: numberAttribute });

  /**
   * The icon actually rendered, after applying the `activeIcon` → `icon` fallback.
   * @protected
   * @computed
   */
  protected readonly _resolvedIcon = computed<string>(() =>
    this.isActive() ? this.activeIcon() || this.icon() : this.icon()
  );

  /**
   * The Forge variant actually applied, after choosing between `variant` and `activeVariant`.
   * @protected
   * @computed
   */
  protected readonly _resolvedVariant = computed<IconButtonVariant>(() =>
    this.isActive() ? this.activeVariant() : this.variant()
  );

  /**
   * The tooltip text and accessible name actually rendered. `disabled` wins over `active`, and both fall
   * back to `description`.
   * @protected
   * @computed
   */
  protected readonly _resolvedDescription = computed<string>(() => {
    if (this.isDisabled()) return this.disabledDescription() || this.description();
    if (this.isActive()) return this.activeDescription() || this.description();
    return this.description();
  });
}
