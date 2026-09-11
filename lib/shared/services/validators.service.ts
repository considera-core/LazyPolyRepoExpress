import { Injectable } from '@angular/core';
import { AbstractControl, FormArray, FormControl, FormGroup, ValidationErrors, ValidatorFn } from '@angular/forms';
import { IFormFieldLabel } from '../interfaces/IFormFieldLabel';

/**
 * Reusable Angular validators plus the error-flattening routine that drives the error summary message.
 *
 * The validators are static so they can be referenced directly where a form is built. `getAllFormErrors` is
 * an instance method because it is consumed through `inject()` by components that render error lists.
 *
 * Every message this service produces is plain English. A consuming app that ships more than one locale should
 * pass its own already-localized labels via {@link IFormFieldLabel} and localize the templates that render the
 * returned strings — this library deliberately takes no `@angular/localize` dependency.
 */
@Injectable({ providedIn: 'root' })
export class ValidatorsService {
  /**
   * Rejects a value containing any whitespace. Use for identifiers and codes, not for names.
   *
   * Typed as a `ValidatorFn` over `AbstractControl` so it can be handed straight to a control's validator list.
   */
  public static noWhitespaceValidator(control: AbstractControl): ValidationErrors | null {
    const value: unknown = control.value;
    return typeof value === 'string' && /\s/.test(value) ? { whitespace: true } : null;
  }

  /**
   * Rejects a value that is not parseable as a number. An empty value passes — pair with `Validators.required`
   * when the field is mandatory.
   */
  public static numberValidator(control: AbstractControl): ValidationErrors | null {
    const value: unknown = control.value;
    if (value === null || value === undefined || value === '') {
      return null;
    }

    return isNaN(Number(value)) ? { notANumber: true } : null;
  }

  /**
   * Applies `required` only while `predicate` returns true, for fields that become mandatory based on another
   * answer in the same form.
   */
  public static requiredIf(predicate: () => boolean): ValidatorFn {
    return (control: AbstractControl): ValidationErrors | null => {
      const isBlank = control.value === null || control.value === undefined || control.value.toString().trim() === '';
      return predicate() && isBlank ? { required: true } : null;
    };
  }

  /**
   * Fails with `message` whenever `predicate` returns true. Use for cross-field rules that have no natural
   * home on a single control.
   */
  public static mustBeFalse(predicate: () => boolean, message: string): ValidatorFn {
    return (): ValidationErrors | null => (predicate() ? { mustBeFalse: message } : null);
  }

  /**
   * Group-level validator requiring at least one of the group's (or array's) controls to hold a value.
   */
  public static atLeastOneFieldValidator(): ValidatorFn {
    return (group: AbstractControl): ValidationErrors | null => {
      const message = 'At least one field must be filled out.';
      const hasValue = (control: AbstractControl): boolean => !!(control.value ?? '').toString().trim();

      if (group instanceof FormGroup) {
        return Object.values(group.controls).some(hasValue) ? null : { atLeastOneRequired: message };
      }

      if (group instanceof FormArray) {
        return group.controls.some(hasValue) ? null : { atLeastOneRequired: message };
      }

      return null;
    };
  }

  /**
   * Resolves a control path to its display label, falling back to the raw path when unmapped.
   */
  public static getFromMap(key: string, map?: IFormFieldLabel[]): string {
    return map?.find((mapping) => mapping.key === key)?.label ?? key;
  }

  /**
   * Walks a control tree and flattens every validation failure into a list of readable sentences.
   *
   * Recurses through nested groups and arrays, building dotted/indexed paths (`address.zip`, `parties[2].name`)
   * so `map` can label deeply nested controls. Group-level errors whose value is a string are passed through
   * verbatim, which is how cross-field validators such as {@link atLeastOneFieldValidator} supply their own
   * wording.
   *
   * @param control The root control to inspect. Returns an empty list when undefined.
   * @param map Control-path-to-label mappings used in the generated messages.
   * @param parentKey Accumulated path of `control`. Callers should leave this at its default.
   */
  public getAllFormErrors(control?: AbstractControl, map?: IFormFieldLabel[], parentKey = ''): string[] {
    if (!control) {
      return [];
    }

    let messages: string[] = [];

    if (control instanceof FormGroup) {
      for (const key of Object.keys(control.controls)) {
        const child = control.get(key);
        const fullKey = parentKey ? `${parentKey}.${key}` : key;
        messages = messages.concat(this.getAllFormErrors(child ?? undefined, map, fullKey));
      }
    } else if (control instanceof FormArray) {
      control.controls.forEach((child, index) => {
        messages = messages.concat(this.getAllFormErrors(child, map, `${parentKey}[${index}]`));
      });
    } else if (control instanceof FormControl) {
      messages = messages.concat(this._describeControlErrors(control.errors, parentKey, map));
    }

    // Group- and array-level errors sit alongside the children's, so they are collected after the recursion.
    if (control.errors && !(control instanceof FormControl)) {
      for (const errorKey of Object.keys(control.errors)) {
        const errorValue: unknown = control.errors[errorKey];
        messages.push(typeof errorValue === 'string' ? errorValue : 'Form is invalid');
      }
    }

    return messages;
  }

  /**
   * Turns a single control's `ValidationErrors` into sentences. Unknown error keys are ignored so an app's own
   * validators can supply their message through a group-level error instead.
   */
  private _describeControlErrors(errors: ValidationErrors | null, key: string, map?: IFormFieldLabel[]): string[] {
    if (!errors) {
      return [];
    }

    const label = ValidatorsService.getFromMap(key, map);
    const messages: string[] = [];

    if (errors.required) messages.push(`${label} cannot be blank.`);
    if (errors.email) messages.push(`${label} requires a valid email address.`);
    if (errors.minlength)
      messages.push(`${label} requires a minimum of ${errors.minlength.requiredLength} characters.`);
    if (errors.maxlength)
      messages.push(`${label} requires a maximum of ${errors.maxlength.requiredLength} characters.`);
    if (errors.whitespace) messages.push(`${label} cannot have spaces.`);
    if (errors.notANumber) messages.push(`${label} is not a valid number.`);
    if (errors.min) messages.push(`${label} must be at least ${errors.min.min}.`);
    if (errors.max) messages.push(`${label} must be at most ${errors.max.max}.`);
    if (errors.pattern) messages.push(`${label} has an invalid format.`);

    return messages;
  }
}
