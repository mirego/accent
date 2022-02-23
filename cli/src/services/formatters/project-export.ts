// Vendor
import chalk from 'chalk';

export default class ProjectExportFormatter {
  log() {
    const title = 'Writing files locally';

    console.log(chalk.gray.dim('⎯'.repeat(title.length - 1)));
    console.log(chalk.magenta(title));

    console.log('');
  }
}
