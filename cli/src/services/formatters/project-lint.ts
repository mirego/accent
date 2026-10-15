import chalk from 'chalk';
import {LintMessage, LintTranslation} from '../../types/lint-translation';
import {
  blank,
  footer,
  formatDuration,
  hint,
  line,
  pluralize,
  symbols,
  title,
  truncate
} from './base';

const MAX_TEXT_SIZE = 200;

const CHECK_MESSAGES: Record<string, string> = {
  placeholder_count: 'Number of placeholders does not match the master string',
  trailing_space: 'String contains a trailing space',
  leading_spaces: 'String contains leading spaces',
  double_spaces: 'String contains double spaces',
  apostrophe_as_single_quote:
    "A single quote (') has been used instead of an apostrophe (’)",
  first_letter_case:
    'First letter does not match the case of the master string',
  three_dots_ellipsis:
    'String contains three dots (...) instead of an ellipsis (…)',
  same_trailing_character:
    'String does not match the trailing character of the master string',
  url_count: 'Number of URLs does not match the master string',
  spelling: 'Spelling or grammar issue'
};

interface Stats {
  time: bigint;
}

export default class ProjectLintFormatter {
  private readonly lintTranslations: LintTranslation[];
  private readonly stats: Stats;

  constructor(lintTranslations: LintTranslation[], stats: Stats) {
    this.lintTranslations = lintTranslations;
    this.stats = stats;
  }

  log() {
    const errorsCount = this.lintTranslations.reduce(
      (memo, {messages}) => memo + messages.length,
      0
    );

    if (errorsCount === 0) {
      footer('No lint errors found', this.stats.time);
      return;
    }

    title('Lint errors', errorsCount);
    blank();

    this.groupByPath().forEach((lintTranslations, path) => {
      line(chalk.underline(path));

      lintTranslations.forEach((lintTranslation) =>
        this.logLintTranslation(lintTranslation)
      );

      blank();
    });

    line(
      `${chalk.red(symbols.error)} Found ${chalk.red.bold(
        pluralize(errorsCount, 'lint error')
      )} ${chalk.dim(`in ${formatDuration(this.stats.time)}`)}`
    );
    hint(
      'Report incorrect results: https://github.com/mirego/accent/issues',
      1
    );
    blank();

    throw {};
  }

  formatMessageCheck(check: string): string {
    return CHECK_MESSAGES[check] || check;
  }

  private groupByPath() {
    const grouped = new Map<string, LintTranslation[]>();

    this.lintTranslations.forEach((lintTranslation) => {
      const list = grouped.get(lintTranslation.path) || [];
      list.push(lintTranslation);
      grouped.set(lintTranslation.path, list);
    });

    return grouped;
  }

  private logLintTranslation(lintTranslation: LintTranslation) {
    line(chalk.bold(lintTranslation.key), 1);

    lintTranslation.messages.forEach((message: LintMessage) => {
      line(
        `${chalk.red(symbols.error)} ${this.formatMessageCheck(message.check)}`,
        2
      );
    });

    const text = lintTranslation.messages[0]?.text ?? lintTranslation.text;
    if (text) {
      line(chalk.dim.italic(JSON.stringify(truncate(text, MAX_TEXT_SIZE))), 2);
    }
  }
}
