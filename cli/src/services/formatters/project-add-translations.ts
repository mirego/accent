// Vendor
import * as chalk from 'chalk';

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

    console.log(
      chalk.white.bold('Adding translations paths →'),
      chalk.white(languages),
      chalk.green('✓')
    );
  }
}
