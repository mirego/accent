// Vendor
import {flags} from '@oclif/command';
import {existsSync} from 'fs';

// Command
import Command, {configFlag} from '../base';

// Formatters
import AddTranslationsFormatter from '../services/formatters/project-add-translations';
import ExportFormatter from '../services/formatters/project-export';
import SyncFormatter from '../services/formatters/project-sync';

// Services
import Document from '../services/document';
import DocumentPathsFetcher from '../services/document-paths-fetcher';
import CommitOperationFormatter from '../services/formatters/commit-operation';
import DocumentExportFormatter from '../services/formatters/document-export';
import HookRunner from '../services/hook-runner';

import {fetchFromRevision} from '../services/revision-slug-fetcher';

// Types
import {Hooks} from '../types/document-config';

export default class Sync extends Command {
  static description =
    'Sync files in Accent and write them to your local filesystem';

  static examples = [
    `$ accent sync`,
    `$ accent sync --dry-run --sync-type=force`,
    `$ accent sync --add-translations --merge-type=smart --order-key=key --version=v0.23`
  ];

  static args = [];

  static flags = {
    'add-translations': flags.boolean({
      description:
        'Add translations in Accent to help translators if you already have translated strings locally'
    }),
    'no-local-write': flags.boolean({
      default: false,
      description:
        'Do not write to the local files _after_ the sync. Warning: This option could lead to a mismatch between the source of truth (your code repository) and Accent'
    }),
    'dry-run': flags.boolean({
      default: false,
      description: 'Do not commit the changes in Accent'
    }),
    'merge-type': flags.string({
      default: 'passive',
      description:
        'Algorithm to use on existing strings when adding translation',
      options: ['smart', 'passive', 'force']
    }),
    'order-by': flags.string({
      default: 'index',
      description: 'Will be used in the export call as the order of the keys',
      options: ['index', 'key']
    }),
    'sync-type': flags.string({
      default: 'smart',
      description:
        'Algorithm to use on existing strings when syncing the main language',
      options: ['smart', 'passive']
    }),
    version: flags.string({
      default: '',
      description:
        'Sync a specific version, the tag needs to exists in Accent first'
    }),
    config: configFlag
  };

  async run() {
    const {flags} = this.parse(Sync);
    const t0 = process.hrtime.bigint();
    const documents = this.projectConfig.files();

    if (this.projectConfig.config.version?.tag && !flags.version) {
      flags.version = this.config.version;
    }

    // From all the documentConfigs, do the sync or peek operations and log the results.
    const syncFormatter = new SyncFormatter();
    syncFormatter.log(this.project!, flags);

    for (const document of documents) {
      await new HookRunner(document).run(Hooks.beforeSync);

      await this.syncDocumentConfig(document);

      await new HookRunner(document).run(Hooks.afterSync);
    }
    // After syncing (and writing) the files in Accent, the list of documents could have changed.
    if (!flags['dry-run']) await this.refreshProject();

    if (this.project!.revisions.length > 1 && flags['add-translations']) {
      new AddTranslationsFormatter().log(this.project!);

      for (const document of documents) {
        await new HookRunner(document).run(Hooks.beforeAddTranslations);

        await this.addTranslationsDocumentConfig(document);

        await new HookRunner(document).run(Hooks.afterAddTranslations);
      }
    }

    if (flags['dry-run']) {
      const t1 = process.hrtime.bigint();
      syncFormatter.footerDryRun(t1 - t0);
      return;
    }

    if (flags['no-local-write']) return;

    const formatter = new DocumentExportFormatter();

    // From all the documentConfigs, do the export, write to local file and log the results.
    new ExportFormatter().log();

    for (const document of documents) {
      await new HookRunner(document).run(Hooks.beforeExport);

      const targets = new DocumentPathsFetcher().fetch(this.project!, document);

      for (const target of targets) {
        const {path, language, documentPath} = target;
        const localFile = document.fetchLocalFile(documentPath, path);
        formatter.log(path, documentPath, language);

        await document.export(localFile, language, documentPath, flags);
      }

      await new HookRunner(document).run(Hooks.afterExport);
    }

    const t2 = process.hrtime.bigint();
    syncFormatter.footer(t2 - t0);
  }

  private async syncDocumentConfig(document: Document) {
    const {flags} = this.parse(Sync);
    const formatter = new CommitOperationFormatter();

    for (const path of document.paths) {
      const operations = await document.sync(this.project!, path, flags);
      const documentPath = document.parseDocumentName(path, document.config);

      if (operations.peek) {
        formatter.logPeek(path, documentPath, operations.peek);
      } else {
        formatter.logSync(path, documentPath);
      }
    }
    console.log('');
  }

  private async addTranslationsDocumentConfig(document: Document) {
    const {flags} = this.parse(Sync);
    const formatter = new CommitOperationFormatter();
    const masterLanguage = fetchFromRevision(this.project!.masterRevision);

    const targets = new DocumentPathsFetcher()
      .fetch(this.project!, document)
      .filter(({language}) => language !== masterLanguage);

    const existingTargets = targets.filter(({path}) => existsSync(path));

    if (existingTargets.length === 0) {
      targets.forEach(({path}) => formatter.logEmptyExistingTarget(path));
    }
    if (targets.length === 0) {
      formatter.logEmptyTarget(document.config.source);
    }

    for (const target of existingTargets) {
      const {path, language} = target;
      const documentPath = document.parseDocumentName(path, document.config);
      const operation = await document.addTranslations(
        path,
        language,
        documentPath,
        flags
      );

      if (!operation.peek) {
        formatter.logAddTranslations(operation.file, operation.documentPath);
      }

      if (operation.peek) {
        formatter.logPeek(
          operation.file,
          operation.documentPath,
          operation.peek
        );
      }
    }
    console.log('');
  }
}
