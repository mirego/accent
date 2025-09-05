import { Command, Flags, ux } from '@oclif/core';
import * as chalk from 'chalk';
import ConfigFetcher from './services/config';
import ProjectFetcher from './services/project-fetcher';
import { Project, ProjectViewer } from './types/project';

const MISSING_PATH = '__MISSING__';

const sleep = async (ms: number) =>
  new Promise((resolve: (value: unknown) => void) => setTimeout(resolve, ms));

export const configFlag = Flags.string({
  char: 'c',
  default: 'accent.json',
  description: 'Path to the config file'
});


function preParseConfigArg(argv: string[]): string {
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i]
    if (a === '--config' || a === '-c') {
      const next = argv[i + 1]
      if (!next || next.startsWith('-')) {
        return MISSING_PATH
      }
      return next
    } else if (a.startsWith('--config=')) {
      return a.split('=')[1] ?? 'accent.json'
    }
  }
  return 'accent.json'
}

export default abstract class BaseCommand extends Command {
  projectConfig!: ConfigFetcher;
  project?: Project;
  viewer?: ProjectViewer;

  async init(): Promise<void> {
    await super.init();

    const configPath = preParseConfigArg(this.argv);
    if (configPath === MISSING_PATH) {
      this.error('Flag --config expects a value (e.g., --config path/to/accent.json)')
    }
    this.projectConfig = new ConfigFetcher(configPath);
    const config = this.projectConfig.config;

    // Fetch project from the GraphQL API.
    ux.action.start(chalk.white(`Fetch config in ${configPath}`));
    await sleep(1000);

    const fetcher = new ProjectFetcher();
    const response = await fetcher.fetch(config);
    this.project = response.project;
    this.viewer = response;

    if (!this.project) this.error('Unable to fetch project');

    ux.action.stop(chalk.green(`${this.viewer.user.fullname} ✓`));

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
