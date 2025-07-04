import Service, {service} from '@ember/service';
import config from 'accent-webapp/config/environment';
import AuthenticatedRequest from 'accent-webapp/services/authenticated-request';

interface ExportAllOptions {
  project: any;
  revision: any;
  version?: string;
  documentFormat: string;
  orderBy?: string;
  filters?: {
    isTextEmptyFilter?: boolean;
    isAddedLastSyncFilter?: boolean;
    isConflictedFilter?: boolean;
  };
}

interface ExportOptions {
  project: any;
  document: any;
  revision: any;
  version?: string;
  documentFormat: string;
  orderBy?: string;
  filters?: {
    isTextEmptyFilter?: boolean;
    isAddedLastSyncFilter?: boolean;
    isConflictedFilter?: boolean;
  };
}

interface JIPTOptions {
  project: any;
  document: any;
  version?: string;
  documentFormat: string;
}

export default class Exporter extends Service {
  @service('authenticated-request')
  declare authenticatedRequest: AuthenticatedRequest;

  async export(options: ExportOptions) {
    const {project, document, revision, version, documentFormat} = options;

    const url = config.API.EXPORT_DOCUMENT;

    /* eslint-disable camelcase */
    return this.authenticatedRequest.export(
      `${url}?${this.queryParams({
        inline_render: true,
        language: revision.language.slug,
        project_id: project.id,
        version,
        order_by: options.orderBy,
        document_path: document.path,
        document_format: (documentFormat || document.format).toLowerCase(),
        'filters[is_text_empty]': options.filters?.isTextEmptyFilter,
        'filters[is_added_last_sync]': options.filters?.isAddedLastSyncFilter,
        'filters[is_conflicted]': options.filters?.isConflictedFilter
      })}`
    );
    /* eslint-enable camelcase */
  }

  async exportAll(options: ExportAllOptions) {
    const {project, revision, version, documentFormat} = options;

    const url = config.API.EXPORT_DOCUMENT;

    /* eslint-disable camelcase */
    return this.authenticatedRequest.export(
      `${url}?${this.queryParams({
        inline_render: true,
        language: revision.language.slug,
        project_id: project.id,
        version,
        order_by: options.orderBy,
        document_format: documentFormat.toLowerCase(),
        'filters[is_text_empty]': options.filters?.isTextEmptyFilter,
        'filters[is_added_last_sync]': options.filters?.isAddedLastSyncFilter,
        'filters[is_conflicted]': options.filters?.isConflictedFilter
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
        document_format: documentFormat
      })}`
    );
    /* eslint-enable camelcase */
  }

  private queryParams(
    params: Record<string, string | null | undefined | boolean>
  ) {
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
