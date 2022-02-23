// Vendor
import chalk from 'chalk';

// Types
import {Project} from '../../types/project';

// Services
import {fetchFromRevision} from '../revision-slug-fetcher';

export default class ProjectAddTranslationsFormatter {
  log(project: Project) {
    const languages = project.revisions
      .filter(
        (revision) =>
          fetchFromRevision(revision) !==
          fetchFromRevision(project.masterRevision)
      )
      .map(fetchFromRevision)
      .join(', ');

    const title = `Adding translations paths (${languages})`;

    console.log(chalk.gray.dim('⎯'.repeat(title.length - 1)));
    console.log(chalk.magenta(title));

    console.log('');
  }
}
