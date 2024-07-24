// Command
import {flags} from '@oclif/command';
import Command, {configFlag} from '../base';

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

  static examples = [
    `$ accent export`,
    `$ accent export --order-by=key --version=build.myapp.com:0.12.345`
  ];

  static args = [];
  static flags = {
    'order-by': flags.string({
      default: 'index',
      description: 'Order of the keys',
      options: ['index', 'key']
    }),
    version: flags.string({
      default: '',
      description: 'Fetch a specific version'
    }),
    config: configFlag
  };

  async run() {
    const {flags} = this.parse(Export);
    const t0 = process.hrtime.bigint();
    const documents = this.projectConfig.files();
    const formatter = new DocumentExportFormatter();

    // From all the documentConfigs, do the export, write to local file and log the results.
    new ExportFormatter().log();

    for (const document of documents) {
      await new HookRunner(document).run(Hooks.beforeExport);

      const targets = new DocumentPathsFetcher().fetch(this.project!, document);

      for (const target of targets) {
        const {path, language, documentPath} = target;
        const localFile = document.fetchLocalFile(documentPath, path);
        formatter.log(localFile, documentPath, language);

        await document.export(localFile, language, documentPath, flags);
      }

      const t2 = process.hrtime.bigint();
      formatter.footer(t2 - t0);

      await new HookRunner(document).run(Hooks.afterExport);
    }
  }
}
