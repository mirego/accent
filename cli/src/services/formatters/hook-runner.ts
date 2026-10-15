import chalk from 'chalk';
import * as decamelize from 'decamelize';
import {blank, humanize, line, symbols} from './base';

const outputLines = (output: string) => output.trimEnd().split('\n');

export default class HookRunnerFomatter {
  log(name: string, commands: string[]) {
    const operation = humanize(decamelize.default(name, {separator: ' '}));
    line(chalk.yellow.bold(`${symbols.hook} Hook: ${operation}`));

    commands.forEach((command) => line(chalk.dim(`$ ${command}`), 1));

    blank();
  }

  error(command: string, errors: string[]) {
    line(`${chalk.red(symbols.error)} ${chalk.red.bold(command)}`);
    errors.flatMap(outputLines).forEach((error) => line(chalk.red(error), 1));
    blank();
  }

  success(command: string, message: string) {
    line(`${chalk.green(symbols.success)} ${chalk.bold(command)}`);
    outputLines(message).forEach((text) => line(chalk.dim(text), 1));
    blank();
  }
}
