// Vendor
import chalk from 'chalk';
import {LintTranslation} from '../../types/lint-translation';
import Base from './base';

// Constants
const MAX_TEXT_SIZE = 30;

// Types
interface Stats {
  time: number;
}

export default class ProjectLintFormatter extends Base {
  private readonly lintTranslations: LintTranslation[];
  private readonly stats: Stats;

  constructor(lintTranslations: LintTranslation[], stats: Stats) {
    super();
    this.lintTranslations = lintTranslations;
    this.stats = stats;
  }

  log() {
    const errorsCount = this.lintTranslations.reduce((memo, {messages}) => {
      return memo + messages.length;
    }, 0);

    if (errorsCount === 0) {
      console.log(
        chalk.gray.dim(this.formatLintingTime(this.stats.time)),
        chalk.green('found no errors.')
      );
      console.log('');
      return;
    } else {
      console.log(chalk.red(`Lint errors (${errorsCount})`));
      console.log('');

      this.lintTranslations.forEach((lintTranslation: LintTranslation) => {
        console.log(
          '  ',
          chalk.white.bold(lintTranslation.key),
          chalk.gray.dim.underline(`${lintTranslation.path}`)
        );

        const message = lintTranslation.messages[0];
        let displayMessage = message.text.slice(0, MAX_TEXT_SIZE);
        if (message.text.length > MAX_TEXT_SIZE)
          displayMessage = `${displayMessage}…`;

        console.log('  ', chalk.white.italic(displayMessage));

        const messagesLength = lintTranslation.messages.map((message: any) => {
          const formattedMessage = this.formatMessageCheck(message.check);
          console.log('   ', chalk.red('•'), formattedMessage);
          return formattedMessage.length;
        });

        const maxMessageLength = Math.max(...messagesLength);

        console.log('  ', chalk.gray.dim('⎯'.repeat(maxMessageLength + 2)));
        console.log('');
      });

      console.log(
        chalk.gray.dim(
          'Please report incorrect results: https://github.com/mirego/accent/issues'
        )
      );
      console.log(
        chalk.gray.dim(this.formatLintingTime(this.stats.time)),
        'found',
        chalk.red(`${errorsCount} linting errors.`)
      );
      console.log('');

      // eslint-disable-next-line no-throw-literal
      throw {};
    }
  }

  formatLintingTime(time: number) {
    return this.formatTiming(
      time,
      (count) => `Linting took ${count} milliseconds,`
    );
  }

  formatMessageCheck(check: string): string {
    switch (check) {
      case 'placeholder_count':
        return 'Number of placeholders does not match the master string';
      case 'trailing_space':
        return 'String contains a trailing space';
      case 'leading_spaces':
        return 'String contains leading spaces';
      case 'double_spaces':
        return 'String contains double spaces';
      case 'apostrophe_as_single_quote':
        return 'A single quote as been used instead of an apostrophe';
      case 'first_letter_case':
        return 'First letter of translation does not match case of the master’s';
      case 'three_dots_ellipsis':
        return 'String contains three dots instead of ellipsis';
      case 'same_trailing_character':
        return 'String does not match the trailing character of master';
      case 'url_count':
        return 'Number of URL does not match the master string';

      default:
        return check;
    }
  }
}
