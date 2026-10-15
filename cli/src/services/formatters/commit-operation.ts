import chalk from 'chalk';
import {PeekOperation, PeekOperationDetail} from '../../types/operation';
import {Project} from '../../types/project';
import {fetchFromRevision} from '../revision-slug-fetcher';
import {blank, empty, fileLine, humanize, line, padEnd, symbols} from './base';

const MASTER_ONLY_ACTIONS = ['new', 'renew', 'remove'];

type DetailedOperation = PeekOperationDetail & {revision: string};

export default class CommitOperationFormatter {
  logSync(path: string, documentPath: string) {
    fileLine(chalk.green(symbols.upload), path, documentPath);
  }

  logAddTranslations(path: string, documentPath: string) {
    fileLine(chalk.green(symbols.upload), path, documentPath);
  }

  logEmptyExistingTarget(path: string) {
    line(chalk.bold(path), 1);
    empty('No local file', 2);
  }

  logEmptyTarget(path: string) {
    line(`${chalk.dim('Source:')} ${chalk.bold(path)}`, 1);
    empty('Translations will be added on write', 2);
  }

  logPeek(path: string, documentPath: string, operations: PeekOperation) {
    fileLine(chalk.cyan(symbols.bullet), path, documentPath);

    const totals = new Map<string, number>();
    Object.values(operations.stats).forEach((actions, index) => {
      Object.entries(actions)
        .filter(
          ([action]) => index === 0 || !MASTER_ONLY_ACTIONS.includes(action)
        )
        .forEach(([action, count]) => {
          totals.set(action, (totals.get(action) || 0) + count);
        });
    });

    if (!totals.size) {
      empty('No changes', 2);
      return;
    }

    const labels = [...totals.keys()].map(humanize);
    const width = Math.max(...labels.map((label) => label.length));

    [...totals.entries()].forEach(([action, count]) => {
      line(
        `${chalk.dim(padEnd(humanize(action), width))}  ${chalk.bold(count)}`,
        2
      );
    });
  }

  logPeekDetails(
    path: string,
    documentPath: string,
    operations: PeekOperation,
    project: Project
  ) {
    fileLine(chalk.cyan(symbols.bullet), path, documentPath);

    const grouped = this.groupOperations(operations, project);

    if (!grouped.size) {
      empty('No changes', 2);
      return;
    }

    const showRevision = Object.keys(operations.operations || {}).length > 1;

    [...grouped.entries()]
      .sort(([a], [b]) => a.localeCompare(b))
      .forEach(([action, list]) => {
        blank();
        line(
          `${chalk.bold(humanize(action))} ${chalk.dim(`(${list.length})`)}`,
          2
        );

        list
          .sort(
            (a, b) =>
              a.key.localeCompare(b.key) || a.revision.localeCompare(b.revision)
          )
          .forEach((operation) =>
            this.logOperation(action, operation, showRevision)
          );
      });
  }

  private groupOperations(operations: PeekOperation, project: Project) {
    const revisionSlugs = new Map(
      project.revisions.map((revision) => [
        revision.id,
        fetchFromRevision(revision)
      ])
    );

    const grouped = new Map<string, DetailedOperation[]>();

    Object.entries(operations.operations || {}).forEach(
      ([revisionId, revisionOperations], index) => {
        revisionOperations
          .filter(
            ({action}) => index === 0 || !MASTER_ONLY_ACTIONS.includes(action)
          )
          .forEach((operation) => {
            const list = grouped.get(operation.action) || [];
            list.push({
              ...operation,
              revision: revisionSlugs.get(revisionId) || revisionId
            });
            grouped.set(operation.action, list);
          });
      }
    );

    return grouped;
  }

  private logOperation(
    action: string,
    operation: DetailedOperation,
    showRevision: boolean
  ) {
    const revision = showRevision ? chalk.dim(`[${operation.revision}] `) : '';
    line(`${revision}${chalk.cyan(operation.key)}`, 3);

    const previousText = operation['previous-text'];
    if (
      action !== 'new' &&
      previousText !== null &&
      previousText !== undefined
    ) {
      line(chalk.red(`- ${JSON.stringify(previousText)}`), 3);
    }

    if (operation.text !== null && operation.text !== undefined) {
      line(chalk.green(`+ ${JSON.stringify(operation.text)}`), 3);
    }
  }
}
