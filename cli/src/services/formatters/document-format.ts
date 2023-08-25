// Vendor
import * as chalk from 'chalk';
import {FormattedFile} from '../../commands/format';
import Base from './base';

// Types
interface Stats {
  time: bigint;
}

export default class DocumentFormatFormatter extends Base {
  private readonly paths: FormattedFile[];
  private readonly stats: Stats;

  constructor(paths: FormattedFile[], stats: Stats) {
    super();
    this.stats = stats;
    this.paths = paths;
  }

  log() {
    console.log(chalk.magenta(`Formatted files (${this.paths.length})`));
    console.log('');

    for (const path of this.paths) {
      console.log(
        '  ',
        path.unchanged ? chalk.white.dim(path.path) : chalk.white(path.path)
      );
    }

    console.log('');
    console.log(chalk.gray.dim(this.formatFormattingTime(this.stats.time)));
    console.log('');
  }

  formatFormattingTime(time: bigint) {
    return this.formatTiming(
      time,
      (count) => `Formatting took ${count} milliseconds`
    );
  }
}
