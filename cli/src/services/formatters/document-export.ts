// Vendor
import chalk from 'chalk';

export default class DocumentExportFormatter {
  log(path: string) {
    console.log('  ', chalk.white(path));
    console.log(
      '  ',
      chalk.green('↓ Successfully wrote local file from Accent')
    );
    console.log('');
  }
}
