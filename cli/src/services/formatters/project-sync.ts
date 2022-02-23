// Vendor
import chalk from 'chalk';

// Types
import {Project} from '../../types/project';

// Services
import {fetchFromRevision} from '../revision-slug-fetcher';
import Base from './base';

export default class ProjectSyncFormatter extends Base {
  log(project: Project) {
    console.log(
      chalk.magenta(
        'Syncing sources',
        `(${fetchFromRevision(project.masterRevision)})`
      )
    );

    console.log('');
  }

  footerDryRun(time: number) {
    console.log(
      chalk.gray.dim(
        'For more informations on operations: https://www.accent.reviews/guides/glossary.html#sync'
      )
    );
    console.log(
      chalk.gray.dim(this.formatSyncingTime(time)),
      'remove --dry-run to commit your changes to the server'
    );
    console.log('');
  }

  footer(time: number) {
    console.log(
      chalk.gray.dim(
        'For more informations on operations: https://www.accent.reviews/guides/glossary.html#sync'
      )
    );
    console.log(
      chalk.gray.dim(this.formatSyncingTime(time)),
      'completed without issues'
    );
    console.log('');
  }

  formatSyncingTime(time: number) {
    return this.formatTiming(
      time,
      (count) => `Syncing took ${count} milliseconds,`
    );
  }
}
