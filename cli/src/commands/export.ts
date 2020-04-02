// Command
import {flags} from '@oclif/command';
import Command from '../base';

// Formatters
import ExportFormatter from '../services/formatters/project-export';

// Services
import DocumentPathsFetcher from '../services/document-paths-fetcher';
import DocumentExportFormatter from '../services/formatters/document-export';
import HookRunner from '../services/hook-runner';

// Types
import {Hooks} from '../types/document-config';

export default class Export extends Command {
  static description =
    'Export files from Accent and write them to your local filesystem';

  static examples = [`$ accent export`];

  static args = [];
  static flags = {
    'order-by': flags.string({
      default: 'index',
      description: 'Will be used in the export call as the order of the keys',
      options: ['index', 'key-asc'],
    }),
  };

  async run() {
    const {flags} = this.parse(Export);

    const documents = this.projectConfig.files();
    const formatter = new DocumentExportFormatter();

    // From all the documentConfigs, do the export, write to local file and log the results.
    new ExportFormatter().log();

    for (const document of documents) {
      await new HookRunner(document).run(Hooks.beforeExport);

      const targets = new DocumentPathsFetcher().fetch(this.project!, document);

      await Promise.all(
        targets.map(async ({path, language, documentPath}) => {
          const localFile = document.fetchLocalFile(documentPath, path);
          if (!localFile) return new Promise((resolve) => resolve());
          formatter.log(localFile);

          return document.export(localFile, language, documentPath, flags);
        })
      );

      await new HookRunner(document).run(Hooks.afterExport);
    }
  }
}
