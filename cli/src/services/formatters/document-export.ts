import chalk from 'chalk';
import {blank, fileLine, footer, symbols} from './base';

export default class DocumentExportFormatter {
  log(path: string, documentPath: string, language: string) {
    fileLine(chalk.green(symbols.download), path, documentPath, language);
  }

  footer(time: bigint) {
    blank();
    footer('Export completed', time);
  }
}
