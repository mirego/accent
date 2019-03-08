// Command
import Command from '../base'

// Formatters
import ExportFormatter from '../services/formatters/project-export'

// Services
import DocumentJiptPathsFetcher from '../services/document-jipt-paths-fetcher'
import DocumentExportFormatter from '../services/formatters/document-export'
import HookRunner from '../services/hook-runner'

// Types
import {Hooks} from '../types/document-config'

export default class Jipt extends Command {
  public static description =
    'Export jipt files from Accent and write them to your local filesystem'

  public static examples = [`$ accent jipt`]

  public static args = [
    {
      description: 'The pseudo language for in-place-translation-editing',
      name: 'pseudoLanguageName',
      required: true
    }
  ]
  public static flags = {}

  public async run() {
    const {args} = this.parse(Jipt)
    const documents = this.projectConfig.files()
    const formatter = new DocumentExportFormatter()

    // From all the documentConfigs, do the export, write to local file and log the results.
    new ExportFormatter().log()

    for (const document of documents) {
      await new HookRunner(document).run(Hooks.beforeExport)

      const targets = new DocumentJiptPathsFetcher().fetch(
        this.project!,
        document,
        args.pseudoLanguageName
      )

      await Promise.all(
        targets.map(({path, documentPath}) => {
          formatter.log(path)
          return document.exportJipt(path, documentPath)
        })
      )

      await new HookRunner(document).run(Hooks.afterExport)
    }
  }
}
