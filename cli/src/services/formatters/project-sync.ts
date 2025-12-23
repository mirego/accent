import * as chalk from 'chalk';
import {Project} from '../../types/project';
import {fetchFromRevision} from '../revision-slug-fetcher';
import Base from './base';

export default class ProjectSyncFormatter extends Base {
  log(project: Project, flags: any) {
    const logFlags = [];
    if (flags.version) logFlags.push(chalk.gray(`${flags.version}`));

    console.log(
      chalk.magenta('Syncing sources'),
      '→',
      chalk.white(
        `${fetchFromRevision(project.masterRevision)}`,
        logFlags.join('') || null
      ),
      chalk.green('✓')
    );
    console.log('');
  }

  footerDryRun(time: bigint) {
    console.log('');
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

  footer(time: bigint) {
    console.log('');
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

  formatSyncingTime(time: bigint) {
    return this.formatTiming(
      time,
      (count) => `Syncing took ${count} milliseconds,`
    );
  }
}
