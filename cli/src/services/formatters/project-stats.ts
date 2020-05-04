// Vendor
import chalk from 'chalk';

// Types
import {Document, Project, Revision} from '../../types/project';

// Services
import {
  fetchFromRevision,
  fetchNameFromRevision,
} from '../revision-slug-fetcher';

export default class ProjectStatsFormatter {
  private readonly project: Project;

  constructor(project: Project) {
    this.project = project;
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

    console.log(chalk.magenta('Name'));
    console.log('  ', chalk.white.bold(this.project.name));
    console.log('');

    console.log(chalk.magenta('Last synced'));
    if (this.project.lastSyncedAt) {
      console.log('  ', chalk.white.bold(this.project.lastSyncedAt));
    } else {
      console.log('  ', chalk.gray.bold('~~ Never synced ~~'));
    }

    console.log('');

    console.log(chalk.magenta('Master language'));
    console.log(
      '  ',
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
          console.log(
            '  ',
            `${chalk.white.bold(
              fetchNameFromRevision(revision)
            )} – ${fetchFromRevision(revision)}`
          );
          console.log('');
        }
      });
    }

    if (this.project.documents.meta.totalEntries !== 0) {
      console.log(
        chalk.magenta(
          'Documents',
          `(${this.project.documents.meta.totalEntries})`
        )
      );
      this.project.documents.entries.forEach((document: Document) => {
        console.log(
          '  ',
          chalk.gray('Format:'),
          chalk.white.bold(document.format)
        );
        console.log('  ', chalk.gray('Path:'), chalk.white.bold(document.path));
        console.log('');
      });
    }

    console.log(chalk.magenta('Strings'));
    console.log(
      '  ',
      chalk.white('# Strings:'),
      chalk.white(`${translationsCount}`)
    );
    console.log(
      '  ',
      chalk.green('✓ Reviewed:'),
      chalk.green(`${reviewedCount}`)
    );
    console.log(
      '  ',
      chalk.red('× In review:'),
      chalk.red(`${conflictsCount}`)
    );
  }
}
