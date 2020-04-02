// Command
import Command from '../base';

// Services
import Formatter from '../services/formatters/project-stats';

export default class Stats extends Command {
  static description = 'Fetch stats from the API and display it beautifully';

  static examples = [`$ accent stats`];

  /* eslint-disable @typescript-eslint/require-await */
  async run() {
    const formatter = new Formatter(this.project!);

    formatter.log();
  }
  /* eslint-enable @typescript-eslint/require-await */
}
