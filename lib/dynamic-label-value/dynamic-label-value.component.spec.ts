import { Component } from '@angular/core';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { ISelectOption } from '@tylertech/forge';
import { DynamicLabelValueComponent } from './dynamic-label-value.component';

/** Drives the component through a real reactive form, which is how every consumer uses it. */
@Component({
  imports: [DynamicLabelValueComponent, ReactiveFormsModule],
  template: `<vanguard-dynamic-label-value
    [formControl]="control"
    [label]="'Country'"
    [valueMode]="valueMode"
    [valueType]="valueType"
    [selectOptions]="selectOptions" />`
})
class HostComponent {
  public readonly control = new FormControl<string>('US', { nonNullable: true });
  public valueMode: 'view' | 'edit' = 'view';
  public valueType: 'text' | 'select' | 'checkbox' = 'text';
  public selectOptions: ISelectOption[] = [];
}

describe('DynamicLabelValueComponent', () => {
  let fixture: ComponentFixture<DynamicLabelValueComponent>;

  function query(selector: string): HTMLElement | null {
    return fixture.nativeElement.querySelector(selector);
  }

  function valueText(): string {
    return query('[slot="value"]')?.textContent?.trim() ?? '';
  }

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [DynamicLabelValueComponent, HostComponent]
    }).compileComponents();

    fixture = TestBed.createComponent(DynamicLabelValueComponent);
  });

  afterEach(() => fixture.destroy());

  describe('view mode', () => {
    beforeEach(() => {
      fixture.componentRef.setInput('label', 'Country');
      fixture.componentRef.setInput('value', 'United States');
      fixture.detectChanges();
    });

    it('should render the label and value as a label-value pair', () => {
      expect(query('[slot="label"]')?.textContent?.trim()).toBe('Country');
      expect(valueText()).toBe('United States');
      expect(query('forge-text-field')).toBeNull();
    });

    it('should render a hidden placeholder rather than nothing when the value is blank', () => {
      fixture.componentRef.setInput('value', '');
      fixture.detectChanges();

      const placeholder = query('[slot="value"]');
      expect(placeholder?.classList.contains('value-placeholder')).toBe(true);
    });

    it("should render a select field's option label rather than its raw value", () => {
      fixture.componentRef.setInput('valueType', 'select');
      fixture.componentRef.setInput('selectOptions', [
        { value: 'US', label: 'United States' },
        { value: 'CA', label: 'Canada' }
      ]);
      fixture.componentRef.setInput('value', 'CA');
      fixture.detectChanges();

      expect(valueText()).toBe('Canada');
    });

    it('should wrap the value in a code element when code is set', () => {
      fixture.componentRef.setInput('code', true);
      fixture.detectChanges();

      expect(query('[slot="value"] code')?.textContent?.trim()).toBe('United States');
    });

    it('should replace the value with a skeleton while loading', () => {
      fixture.componentRef.setInput('loading', true);
      fixture.detectChanges();

      expect(query('forge-skeleton')).not.toBeNull();
      expect(query('[slot="value"]')).toBeNull();
    });

    it("should leave a checkbox unchecked for the string 'false'", () => {
      fixture.componentRef.setInput('valueType', 'checkbox');
      fixture.componentRef.setInput('value', 'false');
      fixture.detectChanges();

      const checkbox = query('forge-checkbox') as HTMLElement & { checked?: boolean };
      expect(checkbox.checked).toBeFalsy();
    });

    it("should check a checkbox for the string 'true'", () => {
      fixture.componentRef.setInput('valueType', 'checkbox');
      fixture.componentRef.setInput('value', 'true');
      fixture.detectChanges();

      const checkbox = query('forge-checkbox') as HTMLElement & { checked?: boolean };
      expect(checkbox.checked).toBe(true);
    });
  });

  describe('edit mode', () => {
    beforeEach(() => {
      fixture.componentRef.setInput('valueMode', 'edit');
      fixture.componentRef.setInput('label', 'Country');
      fixture.componentRef.setInput('value', 'United States');
      fixture.detectChanges();
    });

    it('should render a text field carrying the current value', () => {
      const input = query('input') as HTMLInputElement;
      expect(input.value).toBe('United States');
      expect(query('forge-label-value')).toBeNull();
    });

    it('should forward the requested input type', () => {
      fixture.componentRef.setInput('inputType', 'number');
      fixture.detectChanges();

      expect((query('input') as HTMLInputElement).type).toBe('number');
    });

    it('should associate the label with the input', () => {
      const input = query('input') as HTMLInputElement;
      const label = query('label') as HTMLLabelElement;

      expect(input.id).not.toBe('');
      expect(label.getAttribute('for')).toBe(input.id);
    });

    it('should disable the input when disabled is set', () => {
      fixture.componentRef.setInput('disabled', true);
      fixture.detectChanges();

      expect((query('input') as HTMLInputElement).disabled).toBe(true);
    });

    it('should render a select instead of a text field for a select field', () => {
      fixture.componentRef.setInput('valueType', 'select');
      fixture.detectChanges();

      expect(query('forge-select')).not.toBeNull();
      expect(query('forge-text-field')).toBeNull();
    });
  });

  describe('ids', () => {
    it('should give each instance a distinct input id', () => {
      const second = TestBed.createComponent(DynamicLabelValueComponent);
      fixture.componentRef.setInput('valueMode', 'edit');
      second.componentRef.setInput('valueMode', 'edit');
      fixture.detectChanges();
      second.detectChanges();

      const firstId = (query('input') as HTMLInputElement).id;
      const secondId = (second.nativeElement.querySelector('input') as HTMLInputElement).id;

      expect(firstId).not.toBe(secondId);
      second.destroy();
    });
  });

  describe('as a form control', () => {
    let host: ComponentFixture<HostComponent>;

    beforeEach(() => {
      host = TestBed.createComponent(HostComponent);
      host.componentInstance.valueMode = 'edit';
      host.detectChanges();
    });

    afterEach(() => host.destroy());

    it('should display the value the form wrote into it', () => {
      const input = host.nativeElement.querySelector('input') as HTMLInputElement;
      expect(input.value).toBe('US');
    });

    it('should push typed text back into the bound control', () => {
      const input = host.nativeElement.querySelector('input') as HTMLInputElement;
      input.value = 'CA';
      input.dispatchEvent(new Event('input', { bubbles: true, composed: true }));
      host.detectChanges();

      expect(host.componentInstance.control.value).toBe('CA');
    });

    it('should mark the control touched once edited', () => {
      expect(host.componentInstance.control.touched).toBe(false);

      const input = host.nativeElement.querySelector('input') as HTMLInputElement;
      input.value = 'MX';
      input.dispatchEvent(new Event('input', { bubbles: true, composed: true }));
      host.detectChanges();

      expect(host.componentInstance.control.touched).toBe(true);
    });

    it('should disable the input when the control is disabled', () => {
      host.componentInstance.control.disable();
      host.detectChanges();

      expect((host.nativeElement.querySelector('input') as HTMLInputElement).disabled).toBe(true);
    });
  });
});
