import chalk from 'chalk';

const NANOSECONDS_PER_MILLISECOND = 1000000n;
const INDENT = '  ';

export const symbols = {
  success: '✓',
  error: '✗',
  warning: '⚠',
  bullet: '•',
  arrow: '→',
  upload: '↑',
  download: '↓',
  hook: '➤',
  edit: '✎'
};

export const line = (text = '', depth = 0) => {
  console.log(text ? `${INDENT.repeat(depth)}${text}` : '');
};

export const blank = () => console.log('');

export const title = (text: string, detail?: string | number) => {
  let suffix = '';
  if (typeof detail === 'number') suffix = chalk.dim(` (${detail})`);
  if (typeof detail === 'string' && detail) {
    suffix = ` ${chalk.dim(symbols.arrow)} ${detail}`;
  }
  line(`${chalk.magenta.bold(text)}${suffix}`);
};

export const hint = (text: string, depth = 0) => line(chalk.dim(text), depth);

export const empty = (text: string, depth = 0) =>
  line(chalk.dim.italic(text), depth);

export const pluralize = (count: number, word: string) =>
  `${count} ${word}${count === 1 ? '' : 's'}`;

export const truncate = (text: string, max: number) =>
  text.length > max ? `${text.slice(0, max)}…` : text;

export const humanize = (text: string) => {
  const spaced = text.replace(/_/g, ' ');
  return spaced.charAt(0).toUpperCase() + spaced.slice(1);
};

export const padEnd = (text: string, width: number) =>
  text + ' '.repeat(Math.max(0, width - text.length));

export const formatDuration = (time: bigint) => {
  const milliseconds = Number(time / NANOSECONDS_PER_MILLISECOND);
  if (milliseconds < 1000) return `${milliseconds}ms`;
  return `${(milliseconds / 1000).toFixed(2)}s`;
};

export const footer = (message: string, time: bigint, next?: string) => {
  line(
    `${chalk.green(symbols.success)} ${message} ${chalk.dim(
      `in ${formatDuration(time)}`
    )}`
  );
  if (next) hint(next, 1);
  blank();
};

export const fileLine = (
  symbol: string,
  path: string,
  documentPath: string,
  suffix?: string
) => {
  const parts = [symbol, chalk.bold(path), chalk.dim(documentPath)];
  if (suffix) parts.push(chalk.dim(`${symbols.arrow} ${suffix}`));
  line(parts.join(' '), 1);
};
