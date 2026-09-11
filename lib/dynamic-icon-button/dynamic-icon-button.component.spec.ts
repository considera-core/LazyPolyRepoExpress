import { ComponentFixture, TestBed } from '@angular/core/testing';

import { provideDynamicIconButtonDefaults } from './dynamic-icon-button-defaults.token';
import { DynamicIconButtonComponent } from './dynamic-icon-button.component';

describe('DynamicIconButtonComponent', () => {
  let fixture: ComponentFixture<DynamicIconButtonComponent>;

  /** The host `forge-icon-button`, which carries every pass-through attribute. */
  function button(): HTMLElement {
    const element = fixture.nativeElement.querySelector('forge-icon-button');
    expect(element).not.toBeNull();
    return element as HTMLElement;
  }

  function icon(): HTMLElement | null {
    return fixture.nativeElement.querySelector('forge-icon');
  }

  function tooltip(): HTMLElement {
    const element = fixture.nativeElement.querySelector('forge-tooltip');
    expect(element).not.toBeNull();
    return element as HTMLElement;
  }

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [DynamicIconButtonComponent]
    }).compileComponents();

    fixture = TestBed.createComponent(DynamicIconButtonComponent);
    fixture.componentRef.setInput('icon', 'favorite_border');
    fixture.detectChanges();
  });

  afterEach(() => {
    fixture.destroy();
  });

  describe('resting state', () => {
    it('should render the resting icon in the resting variant', () => {
      expect(icon()?.getAttribute('name')).toBe('favorite_border');
      expect(button().getAttribute('variant')).toBe('icon');
    });

    it('should not render a progress spinner or a disabled attribute', () => {
      expect(fixture.nativeElement.querySelector('forge-circular-progress')).toBeNull();
      expect(button().hasAttribute('disabled')).toBe(false);
    });
  });

  describe('active state', () => {
    it('should swap in the active icon and the active variant', () => {
      fixture.componentRef.setInput('activeIcon', 'favorite');
      fixture.componentRef.setInput('active', true);
      fixture.detectChanges();

      expect(icon()?.getAttribute('name')).toBe('favorite');
      expect(button().getAttribute('variant')).toBe('raised');
    });

    it('should keep the resting icon when no active icon is supplied', () => {
      fixture.componentRef.setInput('active', true);
      fixture.detectChanges();

      expect(icon()?.getAttribute('name')).toBe('favorite_border');
    });

    it('should honor an overridden active variant', () => {
      fixture.componentRef.setInput('activeVariant', 'filled');
      fixture.componentRef.setInput('active', true);
      fixture.detectChanges();

      expect(button().getAttribute('variant')).toBe('filled');
    });
  });

  describe('loading state', () => {
    it('should replace the icon with a progress spinner', () => {
      fixture.componentRef.setInput('loading', true);
      fixture.detectChanges();

      expect(fixture.nativeElement.querySelector('forge-circular-progress')).not.toBeNull();
      expect(icon()).toBeNull();
    });

    it('should restore the icon when loading finishes', () => {
      fixture.componentRef.setInput('loading', true);
      fixture.detectChanges();
      fixture.componentRef.setInput('loading', false);
      fixture.detectChanges();

      expect(fixture.nativeElement.querySelector('forge-circular-progress')).toBeNull();
      expect(icon()?.getAttribute('name')).toBe('favorite_border');
    });
  });

  describe('disabled state', () => {
    it('should set the disabled attribute on the host button', () => {
      fixture.componentRef.setInput('disabled', true);
      fixture.detectChanges();

      expect(button().hasAttribute('disabled')).toBe(true);
    });

    it('should coerce a string attribute value to a boolean', () => {
      fixture.componentRef.setInput('disabled', '');
      fixture.detectChanges();

      expect(button().hasAttribute('disabled')).toBe(true);
    });
  });

  describe('description', () => {
    beforeEach(() => {
      fixture.componentRef.setInput('description', 'Add to favorites');
      fixture.detectChanges();
    });

    it('should use the description as both the accessible name and the tooltip text', () => {
      expect(button().getAttribute('aria-label')).toBe('Add to favorites');
      expect(tooltip().textContent?.trim()).toBe('Add to favorites');
    });

    it('should fall back to the description when active with no active description', () => {
      fixture.componentRef.setInput('active', true);
      fixture.detectChanges();

      expect(button().getAttribute('aria-label')).toBe('Add to favorites');
    });

    it('should use the active description while active', () => {
      fixture.componentRef.setInput('activeDescription', 'Remove from favorites');
      fixture.componentRef.setInput('active', true);
      fixture.detectChanges();

      expect(button().getAttribute('aria-label')).toBe('Remove from favorites');
      expect(tooltip().textContent?.trim()).toBe('Remove from favorites');
    });

    it('should use the disabled description while disabled', () => {
      fixture.componentRef.setInput('disabledDescription', 'Sign in to use favorites');
      fixture.componentRef.setInput('disabled', true);
      fixture.detectChanges();

      expect(button().getAttribute('aria-label')).toBe('Sign in to use favorites');
    });

    it('should prefer the disabled description over the active description', () => {
      fixture.componentRef.setInput('activeDescription', 'Remove from favorites');
      fixture.componentRef.setInput('disabledDescription', 'Sign in to use favorites');
      fixture.componentRef.setInput('active', true);
      fixture.componentRef.setInput('disabled', true);
      fixture.detectChanges();

      expect(button().getAttribute('aria-label')).toBe('Sign in to use favorites');
    });
  });

  describe('Forge pass-through attributes', () => {
    it("should apply Forge's own defaults when the defaults token isn't provided", () => {
      expect(button().getAttribute('density')).toBe('large');
      expect(button().getAttribute('theme')).toBe('default');
      expect(button().getAttribute('shape')).toBe('circular');
    });

    it('should forward density, theme and shape overrides', () => {
      fixture.componentRef.setInput('density', 'small');
      fixture.componentRef.setInput('theme', 'error');
      fixture.componentRef.setInput('shape', 'squared');
      fixture.detectChanges();

      expect(button().getAttribute('density')).toBe('small');
      expect(button().getAttribute('theme')).toBe('error');
      expect(button().getAttribute('shape')).toBe('squared');
    });

    it('should forward the tooltip placement and delay', () => {
      expect(tooltip().getAttribute('placement')).toBe('left');
      expect(tooltip().getAttribute('delay')).toBe('300');

      fixture.componentRef.setInput('tooltipPlacement', 'top');
      fixture.componentRef.setInput('tooltipDelay', 0);
      fixture.detectChanges();

      expect(tooltip().getAttribute('placement')).toBe('top');
      expect(tooltip().getAttribute('delay')).toBe('0');
    });
  });

  describe('provideDynamicIconButtonDefaults', () => {
    it('should change the density and theme every instance starts from', () => {
      TestBed.resetTestingModule();
      TestBed.configureTestingModule({
        imports: [DynamicIconButtonComponent],
        providers: [provideDynamicIconButtonDefaults({ density: 'medium', theme: 'primary' })]
      });

      fixture = TestBed.createComponent(DynamicIconButtonComponent);
      fixture.componentRef.setInput('icon', 'favorite_border');
      fixture.detectChanges();

      expect(button().getAttribute('density')).toBe('medium');
      expect(button().getAttribute('theme')).toBe('primary');
    });

    it('should leave unspecified defaults at their Forge values', () => {
      TestBed.resetTestingModule();
      TestBed.configureTestingModule({
        imports: [DynamicIconButtonComponent],
        providers: [provideDynamicIconButtonDefaults({ theme: 'primary' })]
      });

      fixture = TestBed.createComponent(DynamicIconButtonComponent);
      fixture.componentRef.setInput('icon', 'favorite_border');
      fixture.detectChanges();

      expect(button().getAttribute('density')).toBe('large');
      expect(button().getAttribute('theme')).toBe('primary');
    });
  });
});
