/**
 * Whether a form — or a single field within one — is displaying its value or editing it.
 *
 * This is the switch behind the view/edit toggle in the Edit page pattern: the container holds one signal of
 * this type and passes it to every field it owns.
 */
export type FormOperationType = 'view' | 'edit';
