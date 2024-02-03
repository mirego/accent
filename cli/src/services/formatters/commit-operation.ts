// Vendor
import * as chalk from 'chalk';

// Types
import {PeekOperation} from '../../types/operation';

// Constants
const MASTER_ONLY_ACTIONS = ['new', 'renew', 'remove'];

export default class CommitOperationFormatter {
  logSync(path: string, documentPath: string) {
    console.log(
      '  ',
      chalk.green('↑'),
      chalk.bold.white(path),
      chalk.gray.dim(documentPath)
    );
  }

  logAddTranslations(path: string, documentPath: string) {
    console.log(
      '  ',
      chalk.green('↑'),
      chalk.bold.white(path),
      chalk.gray.dim(documentPath)
    );
  }

  logEmptyExistingTarget(path: string) {
    console.log('  ', chalk.white(path));
    console.log('  ', chalk.gray('~~ No local file ~~'));
    console.log('');
  }

  logEmptyTarget(path: string) {
    console.log('  ', chalk.bold('Source:'), chalk.white(path));
    console.log('  ', chalk.gray('~~ Translations will be added on write ~~'));
    console.log('');
  }

  logPeek(path: string, documentPath: string, operations: PeekOperation) {
    console.log('  ', chalk.bold.white(path), chalk.gray.dim(documentPath));

    if (!Object.keys(operations.stats).length) {
      console.log('  ', chalk.gray('~~ No changes for this file ~~'));
    }

    Object.entries(operations.stats).map((stat, index) => {
      let actions = Object.entries(stat[1]);
      if (index > 0) {
        actions = actions.filter(
          ([action]) => !MASTER_ONLY_ACTIONS.includes(action)
        );
      }

      actions.map(([action, name]) => {
        console.log(
          '  ',
          chalk.bold(this.formatAction(action)),
          ':',
          chalk.bold.white(name)
        );
      });
    });

    console.log('');
  }

  private formatAction(action: string) {
    const capitalized = action.charAt(0).toUpperCase() + action.slice(1);

    return capitalized.replace(/_/g, ' ');
  }
}
