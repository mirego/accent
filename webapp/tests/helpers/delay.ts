export default function (delay: number) {
  return new Promise((resolve) => setTimeout(resolve, delay));
}
