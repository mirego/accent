import fmt from 'simple-fmt';
import Service, {inject as service} from '@ember/service';
import config from 'accent-webapp/config/environment';
import AuthenticatedRequest from 'accent-webapp/services/authenticated-request';

interface SyncOptions {
  revision: any;
  version: any;
  project: any;
  file: File;
  documentPath: string;
  documentFormat: string;
  syncType: string;
}

export default class Syncer extends Service {
  @service('authenticated-request')
  authenticatedRequest: AuthenticatedRequest;

  async sync({
    revision,
    version,
    project,
    file,
    documentPath,
    documentFormat,
    syncType
  }: SyncOptions) {
    const url = fmt(
      config.API.SYNC_PROJECT_PATH,
      project.id,
      revision.language.slug,
      syncType
    );
    documentFormat = documentFormat.toLowerCase();

    return this.authenticatedRequest.commit(url, {
      file,
      documentPath,
      documentFormat,
      version,
      syncType
    });
  }
}

declare module '@ember/service' {
  interface Registry {
    syncer: Syncer;
  }
}
