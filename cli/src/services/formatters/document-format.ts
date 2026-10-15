import chalk from 'chalk';
import {FormattedFile} from '../../commands/format';
import {blank, footer, line, pluralize, symbols, title} from './base';

interface Stats {
  time: bigint;
}

export default class DocumentFormatFormatter {
  private readonly paths: FormattedFile[];
  private readonly stats: Stats;

  constructor(paths: FormattedFile[], stats: Stats) {
    this.stats = stats;
    this.paths = paths;
  }

  log() {
    title('Formatting files', this.paths.length);
    blank();

    for (const path of this.paths) {
      if (path.unchanged) {
        line(`${chalk.dim(symbols.bullet)} ${chalk.dim(path.path)}`, 1);
      } else {
        line(`${chalk.green(symbols.edit)} ${chalk.bold(path.path)}`, 1);
      }
    }

    const changedCount = this.paths.filter(({unchanged}) => !unchanged).length;

    blank();
    footer(
      `Formatted ${pluralize(this.paths.length, 'file')}, ${changedCount} changed`,
      this.stats.time
    );
  }
}
