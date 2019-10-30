// Vendor
import chalk from 'chalk';

// Types
import {Project} from '../../types/project';

export default class ProjectSyncFormatter {
  log(project: Project) {
    console.log(chalk.magenta('Syncing sources', `(${project.language.slug})`));

    console.log('');
  }
}
