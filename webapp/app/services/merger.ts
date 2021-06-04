import fmt from 'simple-fmt';
import Service, {inject as service} from '@ember/service';
import config from 'accent-webapp/config/environment';
import AuthenticatedRequest from 'accent-webapp/services/authenticated-request';

interface MergeOptions {
  project: any;
  revision: any;
  file: File;
  documentPath: string;
  documentFormat: string;
  mergeType: string;
  mergeOptions: string[];
}

export default class Merger extends Service {
  @service('authenticated-request')
  authenticatedRequest: AuthenticatedRequest;

  async merge({
    project,
    revision,
    file,
    documentPath,
    documentFormat,
    mergeType,
    mergeOptions,
  }: MergeOptions) {
    const language = revision.language;
    const url = fmt(
      config.API.MERGE_REVISION_PATH,
      project.id,
      language.slug,
      mergeType,
      mergeOptions.join(',')
    );

    documentFormat = documentFormat.toLowerCase();

    return this.authenticatedRequest.commit(url, {
      file,
      documentPath,
      documentFormat,
    });
  }
}

declare module '@ember/service' {
  interface Registry {
    merger: Merger;
  }
}
