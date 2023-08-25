const NANOSECONDS = 1000000n;

export default class Base {
  formatTiming(time: bigint, template: (time: string) => string) {
    const count = String(time / NANOSECONDS);
    return template(count);
  }
}
