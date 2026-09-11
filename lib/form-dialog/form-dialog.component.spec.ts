import { Component } from '@angular/core';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { FormDialogComponent } from './form-dialog.component';

/** Mirrors how a dialog uses the shell: its own form projected into the body. */
@Component({
  imports: [FormDialogComponent],
  template: `<vanguard-form-dialog entityLabel="User">
    <form data-test="projected-form"><input name="firstName" /></form>
  </vanguard-form-dialog>`
})
class HostComponent {}

describe('FormDialogComponent', () => {
  let fixture: ComponentFixture<FormDialogComponent>;

  function query(selector: string): (HTMLElement & { disabled?: boolean }) | null {
    return fixture.nativeElement.querySelector(selector);
  }

  function heading(): string {
    return query('[slot="start"].forge-typography--heading2')?.textContent?.trim() ?? '';
  }

  function closeButton(): HTMLElement & { disabled?: boolean } {
    return query('forge-icon-button') as HTMLElement & { disabled?: boolean };
  }

  function cancelButton(): HTMLElement & { disabled?: boolean } {
    return query('forge-button[slot="start"]') as HTMLElement & { disabled?: boolean };
  }

  function confirmButton(): (HTMLElement & { disabled?: boolean }) | null {
    return query('forge-button[slot="end"]');
  }

  function click(element: HTMLElement): void {
    element.dispatchEvent(new MouseEvent('click', { bubbles: true, composed: true }));
  }

  /** `[name]` binds to the upgraded element's property, which Forge does not reflect back to an attribute. */
  function iconName(within: HTMLElement | null, selector = 'forge-icon'): string | undefined {
    return (within?.querySelector(selector) as (HTMLElement & { name?: string }) | null)?.name;
  }

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [FormDialogComponent, HostComponent]
    }).compileComponents();

    fixture = TestBed.createComponent(FormDialogComponent);
  });

  afterEach(() => fixture.destroy());

  describe('heading', () => {
    it("should build the heading from the operation's verb and the entity label", () => {
      fixture.componentRef.setInput('entityLabel', 'User');
      fixture.detectChanges();

      expect(heading()).toBe('Edit User');
    });

    it('should use the add verb for an add operation', () => {
      fixture.componentRef.setInput('operation', 'add');
      fixture.componentRef.setInput('entityLabel', 'Party');
      fixture.detectChanges();

      expect(heading()).toBe('Add Party');
    });

    it('should use the view verb for a view operation', () => {
      fixture.componentRef.setInput('operation', 'view');
      fixture.componentRef.setInput('entityLabel', 'Party');
      fixture.detectChanges();

      expect(heading()).toBe('View Party');
    });

    it('should let an explicit heading override the generated one', () => {
      fixture.componentRef.setInput('entityLabel', 'User');
      fixture.componentRef.setInput('heading', 'Change who has access');
      fixture.detectChanges();

      expect(heading()).toBe('Change who has access');
    });
  });

  describe('icon', () => {
    it('should render the named icon before the heading', () => {
      fixture.componentRef.setInput('icon', 'person');
      fixture.detectChanges();

      expect(iconName(fixture.nativeElement, 'forge-icon.heading-icon')).toBe('person');
    });

    it('should omit the heading icon entirely when icon is blank', () => {
      fixture.componentRef.setInput('icon', '');
      fixture.detectChanges();

      expect(query('forge-icon.heading-icon')).toBeNull();
    });
  });

  describe('actions', () => {
    it('should emit cancel from the footer cancel button', () => {
      let emitted = 0;
      fixture.componentInstance.cancel.subscribe(() => emitted++);
      fixture.detectChanges();

      click(cancelButton());

      expect(emitted).toBe(1);
    });

    it("should emit cancel from the header's close button", () => {
      let emitted = 0;
      fixture.componentInstance.cancel.subscribe(() => emitted++);
      fixture.detectChanges();

      click(closeButton());

      expect(emitted).toBe(1);
    });

    it('should emit confirm from the footer confirm button', () => {
      let emitted = 0;
      fixture.componentInstance.confirm.subscribe(() => emitted++);
      fixture.detectChanges();

      click(confirmButton() as HTMLElement);

      expect(emitted).toBe(1);
    });

    it('should offer no confirm action for a view operation', () => {
      fixture.componentRef.setInput('operation', 'view');
      fixture.detectChanges();

      expect(confirmButton()).toBeNull();
      expect(cancelButton()).not.toBeNull();
    });

    it('should disable only confirm when confirmDisabled is set', () => {
      fixture.componentRef.setInput('confirmDisabled', true);
      fixture.detectChanges();

      expect(confirmButton()?.disabled).toBe(true);
      expect(cancelButton().disabled).toBeFalsy();
      expect(closeButton().disabled).toBeFalsy();
    });

    it('should disable every action while busy, so a save cannot be repeated or interrupted', () => {
      fixture.componentRef.setInput('busy', true);
      fixture.detectChanges();

      expect(confirmButton()?.disabled).toBe(true);
      expect(cancelButton().disabled).toBe(true);
      expect(closeButton().disabled).toBe(true);
    });

    it('should coerce a bare attribute into a true flag', () => {
      fixture.componentRef.setInput('confirmDisabled', '');
      fixture.detectChanges();

      expect(confirmButton()?.disabled).toBe(true);
    });
  });

  describe('labels and icons', () => {
    it('should render the supplied action labels', () => {
      fixture.componentRef.setInput('confirmLabel', 'Save user');
      fixture.componentRef.setInput('cancelLabel', 'Discard');
      fixture.detectChanges();

      expect(confirmButton()?.textContent?.trim()).toBe('Save user');
      expect(cancelButton().textContent?.trim()).toBe('Discard');
    });

    it("should use the cancel label as the close button's accessible name", () => {
      fixture.componentRef.setInput('cancelLabel', 'Discard');
      fixture.detectChanges();

      expect(closeButton().getAttribute('aria-label')).toBe('Discard');
    });

    it('should render the supplied action icons', () => {
      fixture.componentRef.setInput('confirmIcon', 'save');
      fixture.componentRef.setInput('cancelIcon', 'arrow_back');
      fixture.detectChanges();

      expect(iconName(confirmButton())).toBe('save');
      expect(iconName(cancelButton())).toBe('arrow_back');
      expect(iconName(closeButton())).toBe('arrow_back');
    });
  });

  describe('projected content', () => {
    it("should place the consumer's form in the scaffold body", () => {
      const host = TestBed.createComponent(HostComponent);
      host.detectChanges();

      const body = host.nativeElement.querySelector('[slot="body"].dialog-body') as HTMLElement;
      expect(body.querySelector('[data-test="projected-form"]')).not.toBeNull();

      host.destroy();
    });
  });
});
