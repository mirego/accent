import chalk from 'chalk';
import {Project} from '../../types/project';
import {fetchFromRevision} from '../revision-slug-fetcher';
import {blank, title} from './base';

export default class ProjectAddTranslationsFormatter {
  log(project: Project) {
    const masterLanguage = fetchFromRevision(project.masterRevision);
    const languages = project.revisions
      .map(fetchFromRevision)
      .filter((language) => language !== masterLanguage)
      .join(', ');

    title('Adding translations', chalk.bold(languages));
    blank();
  }
}
