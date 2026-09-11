import { ChangeDetectionStrategy, Component, Signal, viewChild } from '@angular/core';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { InitialFocusDirective } from './initial-focus.directive';

@Component({
  selector: 'vanguard-initial-focus-host',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [InitialFocusDirective],
  template: `
    <div class="wrapper" [vanguardInitialFocus]="enabled">
      <input id="slotted" />
    </div>
    <input id="elsewhere" />
  `
})
class HostComponent {
  public enabled = true;

  public readonly directive: Signal<InitialFocusDirective> = viewChild.required(InitialFocusDirective);
}

describe('InitialFocusDirective', () => {
  let fixture: ComponentFixture<HostComponent>;

  function slotted(): HTMLInputElement {
    return fixture.nativeElement.querySelector('#slotted');
  }

  function elsewhere(): HTMLInputElement {
    return fixture.nativeElement.querySelector('#elsewhere');
  }

  beforeEach(async () => {
    await TestBed.configureTestingModule({ imports: [HostComponent] }).compileComponents();
    fixture = TestBed.createComponent(HostComponent);
  });

  afterEach(() => {
    document.body.focus();
    fixture.destroy();
  });

  it('should focus the control the host wraps, not the host itself', async () => {
    fixture.detectChanges();
    await fixture.whenStable();

    expect(document.activeElement).toBe(slotted());
  });

  it('should leave focus alone when it is already somewhere else', async () => {
    // Mirrors a user reaching a different field while the view is still rendering.
    fixture.detectChanges();
    elsewhere().focus();
    await fixture.whenStable();

    expect(document.activeElement).toBe(elsewhere());
  });

  it('should not take focus when disabled', async () => {
    fixture.componentInstance.enabled = false;
    fixture.detectChanges();
    await fixture.whenStable();

    expect(document.activeElement).not.toBe(slotted());
  });

  it('should still focus on demand when disabled', async () => {
    fixture.componentInstance.enabled = false;
    fixture.detectChanges();
    await fixture.whenStable();

    fixture.componentInstance.directive().focus();

    expect(document.activeElement).toBe(slotted());
  });

  it('should move focus back even when another element holds it', async () => {
    fixture.detectChanges();
    await fixture.whenStable();
    elsewhere().focus();

    fixture.componentInstance.directive().focus();

    expect(document.activeElement).toBe(slotted());
  });
});
