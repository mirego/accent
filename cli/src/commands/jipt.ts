import {configFlag} from '../base';
import ExportFormatter from '../services/formatters/project-export';
import DocumentJiptPathsFetcher from '../services/document-jipt-paths-fetcher';
import DocumentExportFormatter from '../services/formatters/document-export';
import HookRunner from '../services/hook-runner';
import {Args} from '@oclif/core';
import BaseCommand from '../base';
import {Hooks} from '../types/document-config';

export default class Jipt extends BaseCommand {
  static description =
    'Export jipt files from Accent and write them to your local filesystem';

  static examples = [`$ accent jipt`];

  static args = {
    pseudoLanguageName: Args.string({
      required: true,
      description: 'The pseudo language for in-place-translation-editing'
    })
  } as const;

  static flags = {config: configFlag} as const;

  async run() {
    const {args} = await this.parse(Jipt);
    const t0 = process.hrtime.bigint();
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
        formatter.log(path, documentPath, 'jipt');

        await document.exportJipt(path, documentPath);
      }

      const t2 = process.hrtime.bigint();
      formatter.footer(t2 - t0);

      await new HookRunner(document).run(Hooks.afterExport);
    }
  }
}
