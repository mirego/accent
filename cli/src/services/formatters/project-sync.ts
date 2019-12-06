// Vendor
import chalk from 'chalk';

// Types
import {Project} from '../../types/project';

// Services
import {fetchFromRevision} from '../revision-slug-fetcher';

export default class ProjectSyncFormatter {
  log(project: Project) {
    console.log(
      chalk.magenta(
        'Syncing sources',
        `(${fetchFromRevision(project.masterRevision)})`
      )
    );

    console.log('');
  }
}
