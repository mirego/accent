import chalk from 'chalk';
import {Config} from '../../types/config';
import {Project, Revision} from '../../types/project';
import {
  fetchFromRevision,
  fetchNameFromRevision
} from '../revision-slug-fetcher';
import {getCurrentBranchName} from '../git-branch-fetcher';
import {blank, empty, line, padEnd, symbols, title} from './base';

interface DocumentTarget {
  documentPath: string;
  path: string;
  language: string;
}

const sum = (revisions: Revision[], field: keyof Revision) =>
  revisions.reduce((memo, revision) => memo + Number(revision[field]), 0);

const formatPercentage = (value: number) =>
  `${Number(value.toFixed(2)).toString()}%`;

export default class ProjectStatsFormatter {
  private readonly project: Project;
  private readonly config: Config;
  private readonly targets: DocumentTarget[];
  private readonly version: string | undefined;

  constructor(
    project: Project,
    config: Config,
    targets: DocumentTarget[],
    version?: string
  ) {
    this.project = project;
    this.config = config;
    this.version = version;
    this.targets = targets;
  }

  percentageReviewedString(reviewedCount: number, translationsCount: number) {
    if (translationsCount === 0) return chalk.dim('No strings');

    const percentage = (reviewedCount / translationsCount) * 100;
    const text = `${formatPercentage(percentage)} reviewed`;

    if (percentage === 100) return chalk.green(text);
    if (percentage > 50) return chalk.yellow(text);
    return chalk.red(text);
  }

  log() {
    const {revisions} = this.project;
    const translationsCount = sum(revisions, 'translationsCount');
    const reviewedCount = sum(revisions, 'reviewedCount');

    this.logHeader(reviewedCount, translationsCount);
    this.logOverview();
    this.logLanguages();
    this.logDocuments();
    this.logVersions();
    this.logStrings(translationsCount, reviewedCount);
    this.logOwners();
  }

  private logHeader(reviewedCount: number, translationsCount: number) {
    const logo = this.project.logo || chalk.bgGreen.black.bold(' ^ ');

    line(
      [
        logo,
        chalk.bold(this.project.name),
        chalk.dim(symbols.bullet),
        this.percentageReviewedString(reviewedCount, translationsCount)
      ].join(' ')
    );
    line(chalk.dim('─'.repeat(40)));
    blank();
  }

  private logOverview() {
    const rows: Array<[string, string]> = [
      [
        'Last synced',
        this.project.lastSyncedAt
          ? chalk.bold(this.project.lastSyncedAt)
          : chalk.dim.italic('Never synced')
      ]
    ];

    const gitBranch = getCurrentBranchName();
    if (gitBranch) rows.push(['Git branch', chalk.bold(gitBranch)]);
    if (this.version) rows.push(['Version', chalk.bold(this.version)]);

    rows.push([
      'URL',
      chalk.underline(`${this.config.apiUrl}/app/projects/${this.project.id}`)
    ]);

    this.logRows(rows, 0);
    blank();
  }

  private logLanguages() {
    const {masterRevision, revisions} = this.project;
    const translations = revisions.filter(
      (revision) => revision.id !== masterRevision.id
    );

    title('Languages', revisions.length);

    const labels = [masterRevision, ...translations].map(this.revisionLabel);
    const width = Math.max(...labels.map((label) => label.length));

    line(
      `${chalk.bold(padEnd(labels[0], width))}  ${chalk.dim('main language')}`,
      1
    );

    translations.forEach((revision, index) => {
      line(
        `${padEnd(labels[index + 1], width)}  ${this.percentageReviewedString(
          revision.reviewedCount,
          revision.translationsCount
        )}`,
        1
      );
    });

    blank();
  }

  private logDocuments() {
    const {entries, meta} = this.project.documents;
    if (meta.totalEntries === 0) return;

    title('Documents', meta.totalEntries);

    const findTarget = (path: string) =>
      this.targets.find((target) => target.documentPath === path);

    const matched = entries.filter((document) => findTarget(document.path));
    const unmatched = entries.filter((document) => !findTarget(document.path));
    const width = Math.max(...entries.map(({path}) => path.length));

    matched.forEach((document) => {
      line(
        `${chalk.green(symbols.success)} ${padEnd(document.path, width)}  ${chalk.dim(
          findTarget(document.path)!.path
        )}`,
        1
      );
    });

    unmatched.forEach((document) => {
      line(
        chalk.dim(
          `${symbols.bullet} ${padEnd(document.path, width)}  ${
            document.format
          }, no match in config file`
        ),
        1
      );
    });

    blank();
  }

  private logVersions() {
    const {entries, meta} = this.project.versions;
    if (meta.totalEntries === 0) return;

    title('Versions', meta.totalEntries);

    entries.forEach(({tag}) => {
      if (tag === this.version) {
        line(`${chalk.green(symbols.arrow)} ${chalk.bold(tag)}`, 1);
      } else {
        line(`  ${tag}`, 1);
      }
    });

    blank();
  }

  private logStrings(translationsCount: number, reviewedCount: number) {
    const {revisions} = this.project;

    title('Strings', translationsCount);

    if (translationsCount === 0) {
      empty('No strings', 1);
      blank();
      return;
    }

    this.logRows(
      [
        [
          `${chalk.green(symbols.success)} Reviewed`,
          chalk.green(reviewedCount)
        ],
        [
          `${chalk.red(symbols.error)} In review`,
          chalk.red(sum(revisions, 'conflictsCount'))
        ],
        [
          `${symbols.edit} Translated`,
          chalk.bold(sum(revisions, 'translatedCount'))
        ]
      ],
      1
    );

    blank();
  }

  private logOwners() {
    const owners = this.project.collaborators.filter(
      ({role}) => role === 'OWNER'
    );
    if (owners.length === 0) return;

    title('Owners', owners.length);

    owners.forEach(({user}) => {
      if (user.fullname && user.fullname !== user.email) {
        line(`${chalk.bold(user.fullname)} ${chalk.dim(user.email)}`, 1);
      } else {
        line(user.email, 1);
      }
    });

    blank();
  }

  private revisionLabel(revision: Revision) {
    return `${fetchNameFromRevision(revision)} (${fetchFromRevision(revision)})`;
  }

  private logRows(rows: Array<[string, string]>, depth: number) {
    const visibleLength = (text: string) =>
      text.replace(/\u001b\[[0-9;]*m/g, '').length;
    const width = Math.max(...rows.map(([label]) => visibleLength(label)));

    rows.forEach(([label, value]) => {
      const padding = ' '.repeat(width - visibleLength(label));
      line(`${chalk.dim(label)}${padding}  ${value}`, depth);
    });
  }
}
