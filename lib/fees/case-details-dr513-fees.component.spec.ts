import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CaseDetailsDr513FeesComponent } from './case-details-dr513-fees.component';

describe('CaseDetailsDr513FeesComponent', () => {
  let component: CaseDetailsDr513FeesComponent;
  let fixture: ComponentFixture<CaseDetailsDr513FeesComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CaseDetailsDr513FeesComponent],
    }).compileComponents();

    fixture = TestBed.createComponent(CaseDetailsDr513FeesComponent);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
