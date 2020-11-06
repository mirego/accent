export interface Task {
  isRunning: boolean;
  (): Generator<Promise<unknown>, void, unknown>;
  perform<T>(...args: any[]): Promise<T>;
  cancel(): void;
  cancelAll(): void;
}
