import {
  afterNextRender,
  booleanAttribute,
  Directive,
  ElementRef,
  inject,
  input,
  InputSignalWithTransform
} from '@angular/core';

/**
 * The controls a wrapper element might be standing in for, in the order they should be preferred. A Forge field is
 * a wrapper around a slotted control, so focusing the wrapper itself does nothing useful.
 */
const FOCUSABLE_SELECTOR = [
  'input:not([type="hidden"]):not([disabled])',
  'textarea:not([disabled])',
  'select:not([disabled])',
  '[contenteditable="true"]',
  '[tabindex]:not([tabindex="-1"])'
].join(', ');

/**
 * Focuses the element it is placed on once the view has rendered, for a form whose first field should be ready to
 * type into — a dialog, or a page that exists only to be filled in.
 *
 * Put it on the wrapper rather than the inner control. Given a `forge-text-field` the directive finds the slotted
 * `input` itself; given a Forge element that keeps its control in a shadow root it waits for the element to upgrade
 * and lets it delegate focus, which is what the abstract `InitialFocusDirective` this replaces could not do for
 * `forge-select`.
 *
 * Focus is only taken if nothing else has it yet, so a user who clicks a different field while the view is still
 * rendering is not yanked back to the first one.
 */
@Directive({
  selector: '[vanguardInitialFocus]',
  exportAs: 'vanguardInitialFocus'
})
export class InitialFocusDirective {
  private readonly _host: ElementRef<HTMLElement> = inject(ElementRef);

  /**
   * Whether to take focus on first render. Bind `false` to keep the `focus()` escape hatch — for re-focusing
   * after a rejected submit, say — without the field grabbing focus as the view appears.
   */
  // Typed as `InputSignalWithTransform` rather than `Signal<boolean>`: the narrower type drops the input brand,
  // and a template that binds `[vanguardInitialFocus]` then fails to type-check.
  public readonly vanguardInitialFocus: InputSignalWithTransform<boolean, unknown> = input<boolean, unknown>(true, {
    transform: booleanAttribute
  });

  public constructor() {
    afterNextRender(() => {
      if (this.vanguardInitialFocus()) {
        this._focusIfIdle();
      }
    });
  }

  /**
   * Focuses the target now, whether or not something else currently holds focus.
   *
   * Read the directive off the template with `#field="vanguardInitialFocus"` to reach this.
   */
  public focus(): void {
    const host = this._host.nativeElement;
    const slotted = host.querySelector<HTMLElement>(FOCUSABLE_SELECTOR);

    if (slotted) {
      slotted.focus();
      return;
    }

    // A custom element that has not upgraded has no shadow root to delegate focus into, so `focus()` would be a
    // no-op. Waiting is the whole reason a `forge-select` works here.
    const tagName = host.localName;
    if (tagName.includes('-') && !customElements.get(tagName)) {
      void customElements.whenDefined(tagName).then(() => host.focus());
      return;
    }

    host.focus();
  }

  /**
   * Focus on render is a convenience, not an instruction — if the user has already put focus somewhere else, they
   * have said where they want to be.
   */
  private _focusIfIdle(): void {
    const active = document.activeElement;
    const idle = !active || active === document.body || this._host.nativeElement.contains(active);

    if (idle) {
      this.focus();
    }
  }
}
