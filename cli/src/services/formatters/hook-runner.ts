// Vendor
import chalk from 'chalk'
import * as decamelize from 'decamelize'

const capitalizeFirstLetter = (str: string) =>
  str.charAt(0).toUpperCase() + str.slice(1)

export default class HookRunnerFomatter {
  public log(name: string, commands: string[]) {
    const operation = capitalizeFirstLetter(decamelize(name, ' '))
    console.log(chalk.yellow('➤ '), chalk.bold(chalk.yellow(`${operation}:`)))
    commands.forEach(command => {
      console.log('  ', chalk.yellow(command))
    })
    console.log('')
  }
}
