// Vendor
import * as chalk from 'chalk';

import Base from './base';

export default class DocumentExportFormatter extends Base {
  log(path: string, documentPath: string) {
    console.log(
      '  ',
      chalk.green('↓'),
      chalk.bold.white(documentPath),
      chalk.gray.dim.underline(path)
    );
  }

  footer(time: bigint) {
    console.log('');
    console.log(
      chalk.gray.dim(this.formatTime(time)),
      'completed without issues'
    );
    console.log('');
  }

  formatTime(time: bigint) {
    return this.formatTiming(
      time,
      (count) => `Exporting took ${count} milliseconds,`
    );
  }
}
