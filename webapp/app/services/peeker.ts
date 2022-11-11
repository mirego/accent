import fmt from 'simple-fmt';
import Service, {inject as service} from '@ember/service';
import config from 'accent-webapp/config/environment';
import AuthenticatedRequest from 'accent-webapp/services/authenticated-request';

interface SyncOptions {
  project: any;
  revision: any;
  revisions: any[];
  version: any;
  file: File;
  documentPath: string;
  documentFormat: string;
  syncType: string;
}

interface MergeOptions {
  revision: any;
  version: any;
  project: any;
  file: File;
  mergeType: string;
  mergeOptions: string[];
  documentPath: string;
  documentFormat: string;
}

interface OperationItem {
  action: string;
  key: string;
  text: string;
  'previous-text': string;
}

type Stat = Record<string, number>;

export default class Peeker extends Service {
  @service('authenticated-request')
  authenticatedRequest: AuthenticatedRequest;

  async sync({
    project,
    revision,
    version,
    revisions,
    file,
    documentPath,
    documentFormat,
    syncType,
  }: SyncOptions) {
    const url = fmt(
      config.API.SYNC_PEEK_PROJECT_PATH,
      project.id,
      revision.language.slug,
      syncType
    );

    documentFormat = documentFormat.toLowerCase();

    const {
      data: {operations, stats},
    } = await this.authenticatedRequest.peek(url, {
      file,
      documentPath,
      version,
      documentFormat,
    });

    return revisions.map((revision) =>
      this.mapOperations(revision, operations, stats)
    );
  }

  async merge({
    revision,
    version,
    project,
    file,
    mergeType,
    documentPath,
    documentFormat,
    mergeOptions,
  }: MergeOptions) {
    const url = fmt(
      config.API.MERGE_PEEK_PROJECT_PATH,
      project.id,
      revision.language.slug,
      mergeType,
      mergeOptions.join(',')
    );

    documentFormat = documentFormat.toLowerCase();

    const {
      data: {operations, stats},
    } = await this.authenticatedRequest.peek(url, {
      file,
      version,
      documentPath,
      documentFormat,
    });

    return [this.mapOperations(revision, operations, stats)];
  }

  private mapOperations(
    revision: any,
    operations: Record<number, OperationItem[]>,
    stats: Record<number, Stat>
  ) {
    return {
      language: revision.language,
      stats: this.mapOperationStats(stats[revision.id]),
      operations: this.mapOperationItems(operations[revision.id]),
    };
  }

  private mapOperationStats(stats: Record<string, number>) {
    if (!stats) return [];

    return Object.keys(stats).map((action) => {
      const count = stats[action];

      return {action, count};
    });
  }

  private mapOperationItems(operations: OperationItem[]) {
    if (!operations) return [];

    return operations.map((operation) => {
      return {
        action: operation.action,
        key: operation.key,
        text: operation.text,
        previousText: operation['previous-text'],
      };
    });
  }
}

declare module '@ember/service' {
  interface Registry {
    peeker: Peeker;
  }
}
