import Service, {inject as service} from '@ember/service';
import config from 'accent-webapp/config/environment';
import AuthenticatedRequest from 'accent-webapp/services/authenticated-request';

interface ExportOptions {
  project: any;
  document: any;
  revision: any;
  version: string;
  documentFormat: string;
  orderBy: string;
}

interface JIPTOptions {
  project: any;
  document: any;
  version: string;
  documentFormat: string;
}

export default class Exporter extends Service {
  @service('authenticated-request')
  authenticatedRequest: AuthenticatedRequest;

  async export({
    project,
    document,
    revision,
    version,
    documentFormat,
    orderBy,
  }: ExportOptions) {
    const url = config.API.EXPORT_DOCUMENT;
    documentFormat = (documentFormat || document.format).toLowerCase();

    /* eslint-disable camelcase */
    return this.authenticatedRequest.export(
      `${url}?${this.queryParams({
        inline_render: true,
        language: revision.language.slug,
        project_id: project.id,
        version,
        order_by: orderBy,
        document_path: document.path,
        document_format: documentFormat,
      })}`
    );
    /* eslint-enable camelcase */
  }

  async jipt({project, document, version, documentFormat}: JIPTOptions) {
    const url = config.API.JIPT_EXPORT_DOCUMENT;
    documentFormat = (documentFormat || document.format).toLowerCase();

    /* eslint-disable camelcase */
    return this.authenticatedRequest.export(
      `${url}?${this.queryParams({
        inline_render: true,
        project_id: project.id,
        version,
        document_path: document.path,
        document_format: documentFormat,
      })}`
    );
    /* eslint-enable camelcase */
  }

  private queryParams(params: Record<string, string | null | boolean>) {
    return Object.keys(params)
      .map((key: string) => {
        const value = params[key];

        if (!value) return null;

        return `${encodeURIComponent(key)}=${encodeURIComponent(value)}`;
      })
      .filter((nonNull) => nonNull)
      .join('&');
  }
}

declare module '@ember/service' {
  interface Registry {
    exporter: Exporter;
  }
}
