/**
 * Which control a form field renders for its value.
 *
 * Replaces the numeric `FormValueTypeEnum` the Vanguard apps used, so the value can be written as a plain
 * string attribute in a template without importing anything.
 */
export type FormValueType = 'text' | 'select' | 'checkbox';
