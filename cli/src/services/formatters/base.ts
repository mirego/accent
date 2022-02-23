const NANOSECONDS = 1000000;
const PRECISION = 4;

export default class Base {
  formatTiming(time: number, template: (time: string) => string) {
    const count = (time / NANOSECONDS).toPrecision(PRECISION);
    return template(count);
  }
}
