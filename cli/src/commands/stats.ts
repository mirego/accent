// Command
import Command from '../base';
import {flags} from '@oclif/command';

// Services
import Formatter from '../services/formatters/project-stats';

export default class Stats extends Command {
  static description = 'Fetch stats from the API and display it beautifully';

  static examples = [`$ accent stats`];

  static flags = {
    config: flags.string({
      default: 'accent.json',
      description: 'Path to the config file',
    }),
  };

  /* eslint-disable @typescript-eslint/require-await */
  async run() {
    const {flags} = this.parse(Stats);
    super.initialize(flags['config']);
    const formatter = new Formatter(this.project!, this.projectConfig.config);

    formatter.log();
  }
  /* eslint-enable @typescript-eslint/require-await */
}
