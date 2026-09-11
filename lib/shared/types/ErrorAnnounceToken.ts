import { InjectionToken, WritableSignal, ValueProvider, signal } from '@angular/core';

export const ERROR_ANNOUNCE_VERSION = new InjectionToken<WritableSignal<number>>('Error Announce Version');

export const UNSAVED_CHANGES = new InjectionToken<WritableSignal<boolean>>('Unsaved changes blocker');

export const ErrorAnnounceVersionProvider: ValueProvider = {
  provide: ERROR_ANNOUNCE_VERSION,
  useValue: signal(0)
};

export const UnsavedChangesProvider: ValueProvider = {
  provide: UNSAVED_CHANGES,
  useValue: signal(false)
};
