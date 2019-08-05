import fmt from 'simple-fmt';
import Service, {inject as service} from '@ember/service';
import config from 'accent-webapp/config/environment';

export default Service.extend({
  authenticatedRequest: service('authenticated-request'),

  merge({project, revision, file, documentPath, documentFormat, mergeType}) {
    const language = revision.language;
    const url = fmt(
      config.API.MERGE_REVISION_PATH,
      project.id,
      language.slug,
      mergeType
    );
    documentFormat = documentFormat.toLowerCase();

    return this.authenticatedRequest.commit(url, {
      file,
      documentPath,
      documentFormat
    });
  }
});
