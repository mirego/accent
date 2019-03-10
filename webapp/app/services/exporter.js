import Service, {inject as service} from '@ember/service';
import config from 'accent-webapp/config/environment';

export default Service.extend({
  authenticatedRequest: service('authenticated-request'),

  export({project, document, revision, version, documentFormat, orderBy}) {
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
        document_format: documentFormat
      })}`,
      {}
    );
    /* eslint-enable camelcase */
  },

  jipt({project, document, version, documentFormat}) {
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
      })}`,
      {}
    );
    /* eslint-enable camelcase */
  },

  queryParams(params) {
    return Object.keys(params)
      .map(k => {
        if (!params[k]) return;
        return `${encodeURIComponent(k)}=${encodeURIComponent(params[k])}`;
      })
      .filter(nonNull => nonNull)
      .join('&');
  }
});
