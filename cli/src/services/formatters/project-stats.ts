// Vendor
import chalk from 'chalk';
import {Config} from '../../types/config';

// Types
import {
  Collaborator,
  Document,
  Project,
  Revision,
  Version,
} from '../../types/project';

// Services
import {
  fetchFromRevision,
  fetchNameFromRevision,
} from '../revision-slug-fetcher';
import Base from './base';

const TITLE_LENGTH_PADDING = 4;

export default class ProjectStatsFormatter extends Base {
  private readonly project: Project;
  private readonly config: Config;

  constructor(project: Project, config: Config) {
    super();
    this.project = project;
    this.config = config;
  }

  log() {
    const translationsCount = this.project.revisions.reduce(
      (memo, revision: Revision) => memo + revision.translationsCount,
      0
    );
    const conflictsCount = this.project.revisions.reduce(
      (memo, revision: Revision) => memo + revision.conflictsCount,
      0
    );
    const reviewedCount = this.project.revisions.reduce(
      (memo, revision: Revision) => memo + revision.reviewedCount,
      0
    );
    const percentageReviewed = reviewedCount / translationsCount;

    const percentageReviewedString = `${percentageReviewed}% reviewed`;
    let percentageReviewedFormat = chalk.green(percentageReviewedString);

    if (percentageReviewed === 100) {
      percentageReviewedFormat = chalk.green(percentageReviewedString);
    } else if (percentageReviewed > 100 / 2) {
      percentageReviewedFormat = chalk.yellow(percentageReviewedString);
    } else {
      percentageReviewedFormat = chalk.red(percentageReviewedString);
    }

    console.log(
      this.project.logo ? this.project.logo : chalk.bgGreenBright.bold(' ^ '),
      chalk.white.bold(this.project.name),
      chalk.dim(' • '),
      percentageReviewedFormat
    );
    const titleLength =
      (this.project.logo ? this.project.logo.length + 1 : 0) +
      this.project.name.length +
      percentageReviewedString.length +
      TITLE_LENGTH_PADDING;
    console.log(chalk.gray.dim('⎯'.repeat(titleLength)));

    console.log(chalk.magenta('Last synced'));
    if (this.project.lastSyncedAt) {
      console.log(chalk.white.bold(this.project.lastSyncedAt));
    } else {
      console.log(chalk.gray.bold('~~ Never synced ~~'));
    }

    console.log('');

    console.log(chalk.magenta('Master language'));
    console.log(
      `${chalk.white.bold(
        fetchNameFromRevision(this.project.masterRevision)
      )} – ${fetchFromRevision(this.project.masterRevision)}`
    );

    console.log('');

    if (this.project.revisions.length > 1) {
      console.log(
        chalk.magenta('Translations', `(${this.project.revisions.length - 1})`)
      );
      this.project.revisions.forEach((revision: Revision) => {
        if (this.project.masterRevision.id !== revision.id) {
          const percentageReviewed =
            revision.reviewedCount / revision.translationsCount;

          const percentageReviewedString = `${percentageReviewed}% reviewed`;
          let percentageReviewedFormat = chalk.green(percentageReviewedString);

          if (percentageReviewed === 100) {
            percentageReviewedFormat = chalk.green(percentageReviewedString);
          } else if (percentageReviewed > 100 / 2) {
            percentageReviewedFormat = chalk.yellow(percentageReviewedString);
          } else {
            percentageReviewedFormat = chalk.red(percentageReviewedString);
          }

          console.log(
            `${chalk.white.bold(
              fetchNameFromRevision(revision)
            )} – ${fetchFromRevision(revision)}`,
            chalk.dim('•'),
            percentageReviewedFormat
          );
        }
      });

      console.log('');
    }

    if (this.project.documents.meta.totalEntries !== 0) {
      console.log(
        chalk.magenta(
          'Documents',
          `(${this.project.documents.meta.totalEntries})`
        )
      );
      this.project.documents.entries.forEach((document: Document) => {
        console.log(chalk.gray('Format:'), chalk.white.bold(document.format));
        console.log(chalk.gray('Path:'), chalk.white.bold(document.path));
        console.log('');
      });
    }

    if (this.project.versions.meta.totalEntries !== 0) {
      console.log(
        chalk.magenta(
          'Versions',
          `(${this.project.versions.meta.totalEntries})`
        )
      );
      this.project.versions.entries.forEach((version: Version) => {
        console.log(chalk.bgBlack.white(` ${version.tag} `));
      });
      console.log('');
    }

    console.log(chalk.magenta('Strings'));
    console.log(chalk.white('# Strings:'), chalk.white(`${translationsCount}`));
    console.log(chalk.green('✓ Reviewed:'), chalk.green(`${reviewedCount}`));
    console.log(chalk.red('× In review:'), chalk.red(`${conflictsCount}`));
    console.log('');

    const owners = this.project.collaborators.filter(
      ({role}) => role === 'OWNER'
    );

    if (owners.length !== 0) {
      console.log(chalk.magenta('Owners', `(${owners.length})`));
      owners.forEach((collaborator: Collaborator) => {
        if (collaborator.user.fullname !== collaborator.user.email) {
          console.log(
            chalk.white.bold(collaborator.user.fullname),
            chalk.grey(collaborator.user.email)
          );
        } else {
          console.log(chalk.white(collaborator.user.email));
        }
      });
      console.log('');
    }

    console.log(
      chalk.magenta('Project URL:'),
      chalk.gray.dim(`${this.config.apiUrl}/app/projects/${this.project.id}`)
    );
    console.log('');
  }
}
