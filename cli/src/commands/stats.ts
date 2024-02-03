// Vendor
import * as chalk from 'chalk';

// Command
import {flags} from '@oclif/command';
import Command, {configFlag} from '../base';
import {CLIError} from '@oclif/errors';

// Services
import Formatter from '../services/formatters/project-stats';
import ProjectFetcher from '../services/project-fetcher';
import {Revision} from '../types/project';
import DocumentPathsFetcher from '../services/document-paths-fetcher';

export default class Stats extends Command {
  static description = 'Fetch stats from the API and display them beautifully';

  static examples = [`$ accent stats`];
  static flags = {
    version: flags.string({
      default: undefined,
      description: 'View stats for a specific version',
    }),
    'check-reviewed': flags.boolean({
      description: 'Exit 1 when reviewed percentage is not 100%',
    }),
    'check-translated': flags.boolean({
      description: 'Exit 1 when translated percentage is not 100%',
    }),
    config: configFlag,
  };

  async run() {
    const {flags} = this.parse(Stats);

    if (this.projectConfig.config.version?.tag && !flags.version) {
      flags.version = this.projectConfig.config.version.tag;
    }

    if (flags.version) {
      const config = this.projectConfig.config;
      const fetcher = new ProjectFetcher();
      const response = await fetcher.fetch(config, {versionId: flags.version});

      this.project = response.project;
    }

    const documents = this.projectConfig.files();
    const targets = documents.flatMap((document) => {
      return new DocumentPathsFetcher().fetch(this.project!, document);
    });

    const formatter = new Formatter(
      this.project!,
      this.projectConfig.config,
      targets,
      flags.version
    );

    formatter.log();

    if (flags['check-reviewed']) {
      const conflictsCount = this.project!.revisions.reduce(
        (memo, revision: Revision) => memo + revision.conflictsCount,
        0
      );

      if (conflictsCount !== 0) {
        const versionFormat = flags.version ? ` ${flags.version}` : '';
        throw new CLIError(
          chalk.red(
            `Project${versionFormat} has ${conflictsCount} strings to be reviewed`
          ),
          {exit: 1}
        );
      }
    }

    if (flags['check-translated']) {
      const translatedCount = this.project!.revisions.reduce(
        (memo, revision: Revision) => memo + revision.translatedCount,
        0
      );
      const translationsCount = this.project!.revisions.reduce(
        (memo, revision: Revision) => memo + revision.translationsCount,
        0
      );

      if (translationsCount - translatedCount !== 0) {
        const versionFormat = flags.version ? ` ${flags.version}` : '';
        throw new CLIError(
          chalk.red(
            `Project${versionFormat} has ${translatedCount} strings to be translated`
          ),
          {exit: 1}
        );
      }
    }
  }
}
