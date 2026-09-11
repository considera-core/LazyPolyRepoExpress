/**
 * Every input of `InitialFocusDirective` as a plain object, for driving the Storybook controls and the
 * directive's own configurable demo.
 */
export interface IInitialFocusArgs {
  vanguardInitialFocus: boolean;
}

/** The directive's own defaults, so a demo can highlight which inputs have been changed. */
export const InitialFocusArgsDefault: IInitialFocusArgs = {
  vanguardInitialFocus: true
};
