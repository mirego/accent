// Vendor
import chalk from 'chalk';

// Types
import {Project} from '../../types/project';

export default class ProjectAddTranslationsFormatter {
  log(project: Project) {
    const languages = project.revisions
      .filter(revision => revision.language.slug !== project.language.slug)
      .map(revision => revision.language.slug)
      .join(', ');

    console.log(chalk.magenta('Adding translations paths', `(${languages})`));

    console.log('');
  }
}
