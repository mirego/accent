import * as fs from 'fs';

// Command
import Command, {configFlag} from '../base';
import DocumentPathsFetcher from '../services/document-paths-fetcher';
import Formatter from '../services/formatters/project-lint';
import {LintTranslation} from '../types/lint-translation';

export default class Lint extends Command {
  static description =
    'Lint local files and display errors if any. Exit code is 1 if there are errors.';

  static examples = [`$ accent lint`];
  static flags = {config: configFlag};

  async run() {
    const documents = this.projectConfig.files();
    const results: LintTranslation[] = [];
    const t0 = process.hrtime.bigint();

    for (const document of documents) {
      const targets = new DocumentPathsFetcher()
        .fetch(this.project!, document)
        .sort((a, b) => {
          if (a.path < b.path) return -1;
          if (a.path > b.path) return 1;
          return 0;
        });

      for (const target of targets) {
        const {path, language} = target;
        if (fs.existsSync(path)) {
          const {
            data: {lint_translations: lintTranslations}
          } = (await document.lint(path, language)) as {data: any};

          const lintTranslationsWithLocalPath = lintTranslations.map(
            (lintTranslation: LintTranslation) => ({
              ...lintTranslation,
              path
            })
          );

          results.push(...lintTranslationsWithLocalPath);
        }
      }
    }

    const t2 = process.hrtime.bigint();
    const stats = {time: t2 - t0};

    const formatter = new Formatter(results, stats);

    formatter.log();
  }
}
