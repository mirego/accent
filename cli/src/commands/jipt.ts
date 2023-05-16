// Command
import Command from '../base';
import {flags} from '@oclif/command';

// Formatters
import ExportFormatter from '../services/formatters/project-export';

// Services
import DocumentJiptPathsFetcher from '../services/document-jipt-paths-fetcher';
import DocumentExportFormatter from '../services/formatters/document-export';
import HookRunner from '../services/hook-runner';

// Types
import {Hooks} from '../types/document-config';

export default class Jipt extends Command {
  static description =
    'Export jipt files from Accent and write them to your local filesystem';

  static examples = [`$ accent jipt`];

  static args = [
    {
      description: 'The pseudo language for in-place-translation-editing',
      name: 'pseudoLanguageName',
      required: true,
    },
  ];
  static flags = {
    config: flags.string({
      default: 'accent.json',
      description: 'Path to the config file',
    }),
  };

  async run() {
    const {args} = this.parse(Jipt);
    const {flags} = this.parse(Jipt);
    super.initialize(flags.config);
    const documents = this.projectConfig.files();
    const formatter = new DocumentExportFormatter();

    // From all the documentConfigs, do the export, write to local file and log the results.
    new ExportFormatter().log();

    for (const document of documents) {
      await new HookRunner(document).run(Hooks.beforeExport);

      const targets = new DocumentJiptPathsFetcher().fetch(
        this.project!,
        document,
        args.pseudoLanguageName
      );

      for (const target of targets) {
        const {path, documentPath} = target;
        formatter.log(path, documentPath);

        await document.exportJipt(path, documentPath);
      }

      await new HookRunner(document).run(Hooks.afterExport);
    }
  }
}
