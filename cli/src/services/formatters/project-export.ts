// Vendor
import * as chalk from 'chalk';

export default class ProjectExportFormatter {
  log() {
    const title = 'Writing files locally';

    console.log('');
    console.log(chalk.magenta(title));
  }
}
