// Vendor
import * as chalk from 'chalk';

export default class DocumentExportFormatter {
  log(path: string, documentPath: string) {
    console.log(
      '  ',
      chalk.green('↓'),
      chalk.bold.white(documentPath),
      chalk.gray.dim.underline(path)
    );
  }
  done() {
    console.log('');
  }
}
