import chalk from 'chalk';
import {Project} from '../../types/project';
import {fetchFromRevision} from '../revision-slug-fetcher';
import {blank, footer, title} from './base';

const GLOSSARY_URL = 'https://www.accent.reviews/guides/glossary.html#sync';

export default class ProjectSyncFormatter {
  log(project: Project, flags: {version?: string; 'dry-run'?: boolean}) {
    const details = [chalk.bold(fetchFromRevision(project.masterRevision))];
    if (flags.version) details.push(chalk.dim(`@ ${flags.version}`));
    if (flags['dry-run']) details.push(chalk.yellow('(dry run)'));

    title('Syncing sources', details.join(' '));
    blank();
  }

  footerDryRun(time: bigint) {
    footer(
      'Dry run completed',
      time,
      `Remove --dry-run to commit changes. Operations: ${GLOSSARY_URL}`
    );
  }

  footer(time: bigint) {
    blank();
    footer('Sync completed', time, `Operations: ${GLOSSARY_URL}`);
  }
}
