// Vendor
import * as chalk from 'chalk';

// Command
import { configFlag } from '../base';

// Services
import { Errors, Flags } from '@oclif/core';
import BaseCommand from '../base';
import DocumentPathsFetcher from '../services/document-paths-fetcher';
import Formatter from '../services/formatters/project-stats';
import ProjectFetcher from '../services/project-fetcher';
import { Revision } from '../types/project';

export default class Stats extends BaseCommand {
  static description = 'Fetch stats from the API and display them beautifully';

  static examples = [`$ accent stats`];

  static args = {} as const;

  static flags = {
    version: Flags.string({
      default: undefined,
      description: 'View stats for a specific version'
    }),
    'check-reviewed': Flags.boolean({
      description: 'Exit 1 when reviewed percentage is not 100%'
    }),
    'check-translated': Flags.boolean({
      description: 'Exit 1 when translated percentage is not 100%'
    }),
    config: configFlag
  } as const;

  async run() {
    const { flags } = await this.parse(Stats);
    let version = flags.version

    if (this.projectConfig.config.version?.tag && !version) {
      version = this.projectConfig.config.version.tag;
    }

    if (version) {
      const config = this.projectConfig.config;
      const fetcher = new ProjectFetcher();
      const response = await fetcher.fetch(config, { versionId: version });

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
      version
    );

    formatter.log();

    if (flags['check-reviewed']) {
      const conflictsCount = this.project!.revisions.reduce(
        (memo, revision: Revision) => memo + revision.conflictsCount,
        0
      );

      if (conflictsCount !== 0) {
        const versionFormat = version ? ` ${version}` : '';
        throw new Errors.CLIError(
          chalk.red(
            `Project${versionFormat} has ${conflictsCount} strings to be reviewed`
          ),
          { exit: 1 }
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
        const versionFormat = version ? ` ${version}` : '';
        throw new Errors.CLIError(
          chalk.red(
            `Project${versionFormat} has ${translatedCount} strings to be translated`
          ),
          { exit: 1 }
        );
      }
    }
  }
}
