// Command
import Command from '../base'

// Services
import Formatter from '../services/formatters/project-stats'

export default class Stats extends Command {
  public static description =
    'Fetch stats from the API and display it beautifully'

  public static examples = [`$ accent stats`]

  public async run() {
    const formatter = new Formatter(this.project!)

    formatter.log()
  }
}
