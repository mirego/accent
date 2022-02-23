import * as fs from 'fs';

// Command
import Command from '../base';
import DocumentPathsFetcher from '../services/document-paths-fetcher';
import Formatter from '../services/formatters/project-lint';
import {LintTranslation} from '../types/lint-translation';

export default class Lint extends Command {
  static description =
    'Lint local files and display errors if any. Exit code is 1 if there are errors.';

  static examples = [`$ accent lint`];

  async run() {
    const documents = this.projectConfig.files();
    const results: LintTranslation[] = [];
    const t0 = process.hrtime();

    await Promise.all(
      documents.map(async (document) => {
        const targets = new DocumentPathsFetcher().fetch(
          this.project!,
          document
        );

        return await Promise.all(
          targets.map(async ({path, language}) => {
            if (fs.existsSync(path)) {
              const {
                data: {lint_translations: lintTranslations},
              } = await document.lint(path, language);

              const lintTranslationsWithLocalPath = lintTranslations.map(
                (lintTranslation: LintTranslation) => ({
                  ...lintTranslation,
                  path,
                })
              );

              results.push(...lintTranslationsWithLocalPath);
            }
          })
        );
      })
    );

    const [, t1] = process.hrtime(t0);
    const stats = {time: t1};

    const formatter = new Formatter(results, stats);

    formatter.log();
  }
}
