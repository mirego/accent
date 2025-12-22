import * as chalk from 'chalk';
import * as decamelize from 'decamelize';

const capitalizeFirstLetter = (str: string) =>
  str.charAt(0).toUpperCase() + str.slice(1);

export default class HookRunnerFomatter {
  log(name: string, commands: string[]) {
    const operation = capitalizeFirstLetter(
      decamelize.default(name, {separator: ' '})
    );
    console.log(chalk.yellow('➤'), chalk.bold(chalk.yellow(`${operation}:`)));

    commands.forEach((command) => {
      console.log(' ', chalk.yellow(command));
    });

    console.log('');
  }

  error(command: string, errors: string[]) {
    console.log(chalk.red('⚠'), chalk.bold(chalk.red(`${command}:`)));

    errors.forEach((error) => {
      console.log(' ', chalk.red(error));
    });

    console.log('');
  }

  success(command: string, message: string) {
    console.log(chalk.green('✓'), chalk.bold(chalk.green(`${command}:`)));

    console.log(' ', chalk.green(message));

    console.log('');
  }
}
