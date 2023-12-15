// Vendor
import * as chalk from 'chalk';
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

export default class ProjectStatsFormatter extends Base {
  private readonly project: Project;
  private readonly config: Config;
  private readonly version: string | undefined;

  constructor(project: Project, config: Config, version?: string) {
    super();
    this.project = project;
    this.config = config;
    this.version = version;
  }

  percentageReviewedString(number: number, translationsCount: number) {
    const prettyFloat = (number: string) => {
      if (number.endsWith('.00')) {
        return parseInt(number, 10).toString();
      } else {
        return number;
      }
    };

    const percentageReviewedString = `${prettyFloat(
      number.toFixed(2)
    )}% reviewed`;
    let percentageReviewedFormat = chalk.green(percentageReviewedString);

    if (number === 100) {
      percentageReviewedFormat = chalk.green(percentageReviewedString);
    } else if (number > 100 / 2) {
      percentageReviewedFormat = chalk.yellow(percentageReviewedString);
    } else if (number <= 0 && translationsCount === 0) {
      percentageReviewedFormat = chalk.dim('No strings');
    } else {
      percentageReviewedFormat = chalk.red(percentageReviewedString);
    }

    return percentageReviewedFormat;
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
    const percentageReviewed =
      translationsCount > 0 ? (reviewedCount / translationsCount) * 100 : 0;

    const percentageReviewedFormat = this.percentageReviewedString(
      percentageReviewed,
      translationsCount
    );

    console.log(
      this.project.logo
        ? this.project.logo
        : chalk.bgGreenBright.black.bold(' ^ '),
      chalk.white.bold(this.project.name),
      chalk.dim(' • '),
      percentageReviewedFormat
    );
    console.log(chalk.gray.dim('⎯'));

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
            (revision.reviewedCount / revision.translationsCount) * 100;

          const percentageReviewedFormat = this.percentageReviewedString(
            percentageReviewed,
            translationsCount
          );

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
        if (version.tag === this.version) {
          console.log(chalk.bgBlack.whiteBright(` ${version.tag} `));
        } else {
          console.log(chalk.white(`${version.tag}`));
        }
      });
      console.log('');
    }

    console.log(chalk.magenta(`Strings (${translationsCount})`));
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
