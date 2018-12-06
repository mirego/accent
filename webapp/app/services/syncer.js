import fmt from 'npm:simple-fmt';
import Service, {inject as service} from '@ember/service';
import config from 'accent-webapp/config/environment';

export default Service.extend({
  authenticatedRequest: service('authenticated-request'),

  sync({revision, project, file, documentPath, documentFormat, syncType}) {
    const url = fmt(config.API.SYNC_PROJECT_PATH, project.id, revision.language.slug);
    documentFormat = documentFormat.toLowerCase();

    return this.authenticatedRequest.commit(url, {
      file,
      documentPath,
      documentFormat,
      syncType
    });
  }
});
