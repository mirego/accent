// Vendor
import chalk from 'chalk'

// Types
import {PeekOperation} from '../../types/operation'

// Constants
const MASTER_ONLY_ACTIONS = ['new', 'renew', 'remove']

export default class CommitOperationFormatter {
  public logSync(path: string) {
    console.log('  ', chalk.white(path))
    console.log('  ', chalk.green('✓ Successfully synced the files in Accent'))
    console.log('')
  }

  public logAddTranslations(path: string) {
    console.log('  ', chalk.white(path))
    console.log('  ', chalk.green('✓ Successfully add translations in Accent'))
    console.log('')
  }

  public logPeek(path: string, operations: PeekOperation) {
    console.log('  ', chalk.white(path))

    if (!Object.keys(operations.stats).length) {
      console.log('  ', chalk.gray('~~ No changes for this file ~~'))
    }

    Object.entries(operations.stats).map((stat, index) => {
      let actions = Object.entries(stat[1])
      if (index > 0) {
        actions = actions.filter(
          ([action]) => !MASTER_ONLY_ACTIONS.includes(action)
        )
      }

      actions.map(([action, name]) => {
        console.log(
          '  ',
          chalk.bold(this.formatAction(action)),
          ':',
          chalk.bold.white(name)
        )
      })
    })

    console.log('')
  }

  private formatAction(action: string) {
    const capitalized = action.charAt(0).toUpperCase() + action.slice(1)
    return capitalized.replace(/_/g, ' ')
  }
}
