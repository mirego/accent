// Vendor
import {flags} from '@oclif/command'
import {existsSync} from 'fs'

// Command
import Command from '../base'

// Formatters
import AddTranslationsFormatter from '../services/formatters/project-add-translations'
import ExportFormatter from '../services/formatters/project-export'
import SyncFormatter from '../services/formatters/project-sync'

// Services
import Document from '../services/document'
import DocumentPathsFetcher from '../services/document-paths-fetcher'
import CommitOperationFormatter from '../services/formatters/commit-operation'
import DocumentExportFormatter from '../services/formatters/document-export'
import HookRunner from '../services/hook-runner'

// Types
import {Hooks} from '../types/document-config'

export default class Sync extends Command {
  public static description =
    'Sync files in Accent and write them to your local filesystem'

  public static examples = [`$ accent sync`]

  public static args = []

  public static flags = {
    'add-translations': flags.boolean({
      description:
        'Add translations in Accent to help translators if you already have translated strings'
    }),
    'merge-type': flags.string({
      default: 'smart',
      description:
        'Will be used in the add translations call as the "merge_type" param',
      options: ['smart', 'passive', 'force']
    }),
    'order-by': flags.string({
      default: 'index',
      description: 'Will be used in the export call as the order of the keys',
      options: ['index', 'key-asc']
    }),
    'sync-type': flags.string({
      default: 'smart',
      description: 'Will be used in the sync call as the "sync_type" param',
      options: ['smart', 'passive']
    }),
    write: flags.boolean({
      description: 'Write the file from the export _after_ the operation'
    })
  }

  public async run() {
    const {flags} = this.parse(Sync)

    const documents = this.projectConfig.files()

    // From all the documentConfigs, do the sync or peek operations and log the results.
    new SyncFormatter().log()

    for (const document of documents) {
      await new HookRunner(document).run(Hooks.beforeSync)

      await Promise.all(this.syncDocumentConfig(document))

      await new HookRunner(document).run(Hooks.afterSync)
    }

    if (flags['add-translations']) {
      new AddTranslationsFormatter().log()

      for (const document of documents) {
        await new HookRunner(document).run(Hooks.beforeAddTranslations)

        await Promise.all(this.addTranslationsDocumentConfig(document))

        await new HookRunner(document).run(Hooks.afterAddTranslations)
      }
    }

    if (!flags.write) return
    // After syncing the files in Accent, the list of documents could have changed.
    await this.refreshProject()

    const formatter = new DocumentExportFormatter()

    // From all the documentConfigs, do the export, write to local file and log the results.
    new ExportFormatter().log()

    for (const document of documents) {
      await new HookRunner(document).run(Hooks.beforeExport)

      const targets = new DocumentPathsFetcher().fetch(this.project!, document)

      await Promise.all(
        targets.map(({path, language, documentPath}) => {
          formatter.log(path)
          return document.export(path, language, documentPath, flags)
        })
      )

      await new HookRunner(document).run(Hooks.afterExport)
    }
  }

  private syncDocumentConfig(document: Document) {
    const {flags} = this.parse(Sync)
    const formatter = new CommitOperationFormatter()

    return document.paths.map(async path => {
      const operations = await document.sync(path, flags)

      if (operations.sync && !operations.peek) formatter.logSync(path)
      if (operations.peek) formatter.logPeek(path, operations.peek)

      return operations
    })
  }

  private addTranslationsDocumentConfig(document: Document) {
    const {flags} = this.parse(Sync)
    const formatter = new CommitOperationFormatter()

    const targets = new DocumentPathsFetcher()
      .fetch(this.project!, document)
      .filter(({language}) => language !== document.config.language)
      .filter(({path}) => existsSync(path))

    return targets.map(async ({path, language, documentPath}) => {
      const operations = await document.addTranslations(
        path,
        language,
        documentPath,
        flags
      )

      if (operations.addTranslations && !operations.peek) {
        formatter.logAddTranslations(path)
      }
      if (operations.peek) formatter.logPeek(path, operations.peek)

      return operations
    })
  }
}
