import { TestBed } from '@angular/core/testing';
import { FormArray, FormControl, FormGroup, Validators } from '@angular/forms';
import { ValidatorsService } from './validators.service';

describe('ValidatorsService', () => {
  let service: ValidatorsService;

  beforeEach(() => {
    service = TestBed.inject(ValidatorsService);
  });

  describe('noWhitespaceValidator', () => {
    it('should reject a value containing whitespace', () => {
      expect(ValidatorsService.noWhitespaceValidator(new FormControl('ab cd'))).toEqual({ whitespace: true });
    });

    it('should accept a value with no whitespace', () => {
      expect(ValidatorsService.noWhitespaceValidator(new FormControl('abcd'))).toBeNull();
    });

    it('should accept a null value, leaving emptiness to Validators.required', () => {
      expect(ValidatorsService.noWhitespaceValidator(new FormControl(null))).toBeNull();
    });
  });

  describe('numberValidator', () => {
    it('should reject a value that is not a number', () => {
      expect(ValidatorsService.numberValidator(new FormControl('12a'))).toEqual({ notANumber: true });
    });

    it('should accept a numeric string', () => {
      expect(ValidatorsService.numberValidator(new FormControl('-12.5'))).toBeNull();
    });

    it('should accept an empty value, leaving emptiness to Validators.required', () => {
      expect(ValidatorsService.numberValidator(new FormControl(''))).toBeNull();
    });
  });

  describe('requiredIf', () => {
    it('should require a value while the predicate holds', () => {
      const validator = ValidatorsService.requiredIf(() => true);
      expect(validator(new FormControl('   '))).toEqual({ required: true });
    });

    it('should allow a blank value while the predicate does not hold', () => {
      const validator = ValidatorsService.requiredIf(() => false);
      expect(validator(new FormControl(''))).toBeNull();
    });

    it('should follow the predicate as it changes', () => {
      let mandatory = false;
      const control = new FormControl(
        '',
        ValidatorsService.requiredIf(() => mandatory)
      );
      expect(control.valid).toBe(true);

      mandatory = true;
      control.updateValueAndValidity();

      expect(control.valid).toBe(false);
    });
  });

  describe('mustBeFalse', () => {
    it('should fail with the supplied message while the predicate holds', () => {
      const validator = ValidatorsService.mustBeFalse(() => true, 'Start date must precede end date.');
      expect(validator(new FormControl(null))).toEqual({ mustBeFalse: 'Start date must precede end date.' });
    });

    it('should pass while the predicate does not hold', () => {
      const validator = ValidatorsService.mustBeFalse(() => false, 'Start date must precede end date.');
      expect(validator(new FormControl(null))).toBeNull();
    });
  });

  describe('atLeastOneFieldValidator', () => {
    it('should fail a group whose every control is blank', () => {
      const group = new FormGroup({ home: new FormControl(''), work: new FormControl('   ') });
      expect(ValidatorsService.atLeastOneFieldValidator()(group)).toEqual({
        atLeastOneRequired: 'At least one field must be filled out.'
      });
    });

    it('should pass a group with one filled control', () => {
      const group = new FormGroup({ home: new FormControl(''), work: new FormControl('555') });
      expect(ValidatorsService.atLeastOneFieldValidator()(group)).toBeNull();
    });

    it('should apply the same rule to a form array', () => {
      const empty = new FormArray([new FormControl(''), new FormControl(null)]);
      const filled = new FormArray([new FormControl(''), new FormControl('x')]);

      expect(ValidatorsService.atLeastOneFieldValidator()(empty)).not.toBeNull();
      expect(ValidatorsService.atLeastOneFieldValidator()(filled)).toBeNull();
    });

    it('should ignore a plain control', () => {
      expect(ValidatorsService.atLeastOneFieldValidator()(new FormControl(''))).toBeNull();
    });
  });

  describe('getFromMap', () => {
    it('should resolve a mapped key to its label', () => {
      expect(ValidatorsService.getFromMap('zip', [{ key: 'zip', label: 'ZIP code' }])).toBe('ZIP code');
    });

    it('should fall back to the raw key when unmapped', () => {
      expect(ValidatorsService.getFromMap('zip', [{ key: 'city', label: 'City' }])).toBe('zip');
    });

    it('should fall back to the raw key when no map is supplied', () => {
      expect(ValidatorsService.getFromMap('zip')).toBe('zip');
    });
  });

  describe('getAllFormErrors', () => {
    it('should return an empty list for no control', () => {
      expect(service.getAllFormErrors(undefined)).toEqual([]);
    });

    it('should return an empty list for a valid form', () => {
      const form = new FormGroup({ name: new FormControl('Ada', Validators.required) });
      expect(service.getAllFormErrors(form)).toEqual([]);
    });

    it('should describe each built-in failure in the order the controls are declared', () => {
      const form = new FormGroup({
        name: new FormControl('', Validators.required),
        email: new FormControl('nope', Validators.email),
        code: new FormControl('a b', ValidatorsService.noWhitespaceValidator),
        count: new FormControl('x', ValidatorsService.numberValidator)
      });

      expect(service.getAllFormErrors(form)).toEqual([
        'name cannot be blank.',
        'email requires a valid email address.',
        'code cannot have spaces.',
        'count is not a valid number.'
      ]);
    });

    it('should include the bound length, min, max and pattern details', () => {
      const form = new FormGroup({
        short: new FormControl('a', Validators.minLength(3)),
        long: new FormControl('abcd', Validators.maxLength(2)),
        low: new FormControl(1, Validators.min(5)),
        high: new FormControl(9, Validators.max(5)),
        shaped: new FormControl('abc', Validators.pattern(/^\d+$/))
      });

      expect(service.getAllFormErrors(form)).toEqual([
        'short requires a minimum of 3 characters.',
        'long requires a maximum of 2 characters.',
        'low must be at least 5.',
        'high must be at most 5.',
        'shaped has an invalid format.'
      ]);
    });

    it('should report every failure on a single control', () => {
      const form = new FormGroup({
        code: new FormControl('a b', [Validators.minLength(5), ValidatorsService.noWhitespaceValidator])
      });

      expect(service.getAllFormErrors(form)).toEqual([
        'code requires a minimum of 5 characters.',
        'code cannot have spaces.'
      ]);
    });

    it('should build dotted paths through nested groups so the map can label them', () => {
      const form = new FormGroup({
        address: new FormGroup({ zip: new FormControl('', Validators.required) })
      });

      expect(service.getAllFormErrors(form)).toEqual(['address.zip cannot be blank.']);
      expect(service.getAllFormErrors(form, [{ key: 'address.zip', label: 'ZIP code' }])).toEqual([
        'ZIP code cannot be blank.'
      ]);
    });

    it('should build indexed paths through form arrays', () => {
      const form = new FormGroup({
        parties: new FormArray([new FormControl('Ada', Validators.required), new FormControl('', Validators.required)])
      });

      expect(service.getAllFormErrors(form)).toEqual(['parties[1] cannot be blank.']);
    });

    it("should pass a group-level validator's own string message through verbatim", () => {
      const form = new FormGroup(
        { home: new FormControl(''), work: new FormControl('') },
        { validators: ValidatorsService.atLeastOneFieldValidator() }
      );

      expect(service.getAllFormErrors(form)).toEqual(['At least one field must be filled out.']);
    });

    it('should report a generic sentence for a non-string group-level error', () => {
      const form = new FormGroup({ name: new FormControl('Ada') }, { validators: () => ({ mismatch: true }) });

      expect(service.getAllFormErrors(form)).toEqual(['Form is invalid']);
    });

    it("should collect a group's own error after its children's", () => {
      const form = new FormGroup(
        { name: new FormControl('', Validators.required) },
        { validators: ValidatorsService.mustBeFalse(() => true, 'The group is wrong.') }
      );

      expect(service.getAllFormErrors(form)).toEqual(['name cannot be blank.', 'The group is wrong.']);
    });

    it('should ignore an error key it has no wording for, leaving the message to a group validator', () => {
      const form = new FormGroup({ name: new FormControl('', () => ({ someAppRule: true })) });

      expect(service.getAllFormErrors(form)).toEqual([]);
    });
  });
});
