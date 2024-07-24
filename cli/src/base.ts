// Vendor
import Command from '@oclif/command';
import {error} from '@oclif/errors';
import * as chalk from 'chalk';
import cli from 'cli-ux';
import {flags} from '@oclif/command';

// Services
import ConfigFetcher from './services/config';
import ProjectFetcher from './services/project-fetcher';

// Types
import {Project, ProjectViewer} from './types/project';

const sleep = async (ms: number) =>
  new Promise((resolve: (value: unknown) => void) => setTimeout(resolve, ms));

export const configFlag = flags.string({
  default: 'accent.json',
  description: 'Path to the config file'
});

const parseConfigFlag = (argv: string[]) => {
  const configFlag = argv.findIndex((arg) => arg.match('--config'));
  if (configFlag >= 0 && !argv[configFlag + 1])
    error('Flag --config expects a value');

  return (configFlag >= 0 ? argv[configFlag + 1] : null) || 'accent.json';
};

export default abstract class extends Command {
  projectConfig!: ConfigFetcher;
  project?: Project;
  viewer?: ProjectViewer;

  async init() {
    const configFlag = parseConfigFlag(this.argv);
    this.projectConfig = new ConfigFetcher(configFlag);

    const config = this.projectConfig.config;

    // Fetch project from the GraphQL API.
    cli.action.start(chalk.white(`Fetch config in ${configFlag}`));
    await sleep(1000);

    const fetcher = new ProjectFetcher();
    const response = await fetcher.fetch(config);
    this.project = response.project;
    this.viewer = response;

    if (!this.project) error('Unable to fetch project');

    cli.action.stop(chalk.green(`${this.viewer.user.fullname} ✓`));

    if (this.projectConfig.warnings.length) {
      console.log('');
      console.log(chalk.yellow.bold('Warnings:'));
    }

    this.projectConfig.warnings.forEach((warning) =>
      console.log(chalk.yellow(warning))
    );
    console.log('');
  }

  async refreshProject() {
    const config = this.projectConfig.config;

    const fetcher = new ProjectFetcher();
    const response = await fetcher.fetch(config);
    this.project = response.project;
    this.viewer = response;
  }
}
