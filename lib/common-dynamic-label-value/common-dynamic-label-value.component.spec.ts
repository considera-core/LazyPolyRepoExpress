import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CommonDynamicLabelValueComponent } from './common-dynamic-label-value.component';

describe('CommonDynamicLabelValueComponent', () => {
  let component: CommonDynamicLabelValueComponent;
  let fixture: ComponentFixture<CommonDynamicLabelValueComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CommonDynamicLabelValueComponent],
    }).compileComponents();

    fixture = TestBed.createComponent(CommonDynamicLabelValueComponent);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
