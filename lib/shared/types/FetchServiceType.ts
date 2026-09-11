import { Observable } from 'rxjs';

/**
 * A higher-order function type that returns an observable of values based on
 * the provided filter, index, and size. It's intended to be used for fetching
 * autocomplete options, but it can be used as a table paginator as well.
 *
 * The magic behind this type is that it allows infinite loading over data that
 * has already been fetched (using `of()`) OR over a service call.
 */
export type FetchServiceType<T> = (filter: string, pageIndex: number, pageSize: number) => Observable<T[]>;
