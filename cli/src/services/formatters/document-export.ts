// Vendor
import * as chalk from 'chalk';

import Base from './base';

export default class DocumentExportFormatter extends Base {
  log(path: string, documentPath: string, language: string) {
    console.log(
      '  ',
      chalk.green('↓'),
      chalk.bold.white(path),
      chalk.gray.dim(documentPath),
      chalk.gray.dim(`→ ${language}`)
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
