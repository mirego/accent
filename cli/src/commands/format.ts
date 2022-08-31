import * as fs from 'fs';

// Command
import {flags} from '@oclif/command';
import Command from '../base';
import DocumentPathsFetcher from '../services/document-paths-fetcher';
import DocumentFormatter from '../services/formatters/document-format';

export interface FormattedFile {
  path: string;
  unchanged: boolean;
}

export default class Format extends Command {
  static description =
    'Format local files from server. Exit code is 1 if there are errors.';

  static examples = [`$ accent format`];

  static flags = {
    'order-by': flags.string({
      default: 'index',
      description: 'Order of the keys',
      options: ['index', 'key'],
    }),
  };

  async run() {
    const documents = this.projectConfig.files();
    const t0 = process.hrtime();
    const formattedPaths: FormattedFile[] = [];

    await Promise.all(
      documents.map(async (document) => {
        const targets = new DocumentPathsFetcher().fetch(
          this.project!,
          document
        );

        return await Promise.all(
          targets.map(async ({path, language}) => {
            if (fs.existsSync(path)) {
              const beforeContent = fs.readFileSync(path);
              await document.format(path, language);
              const unchanged = fs.readFileSync(path).equals(beforeContent);

              formattedPaths.push({path, unchanged});
            }
          })
        );
      })
    );

    const [, t1] = process.hrtime(t0);
    const stats = {time: t1};

    const formatter = new DocumentFormatter(formattedPaths, stats);

    formatter.log();
  }
}
