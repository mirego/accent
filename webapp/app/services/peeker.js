import fmt from 'npm:simple-fmt';
import EmberObject from '@ember/object';
import Service, {inject as service} from '@ember/service';
import config from 'accent-webapp/config/environment';

export default Service.extend({
  authenticatedRequest: service('authenticated-request'),

  sync({project, revision, revisions, file, documentPath, documentFormat}) {
    const url = fmt(config.API.SYNC_PEEK_PROJECT_PATH, project.id, revision.language.slug);
    documentFormat = documentFormat.toLowerCase();

    return this.authenticatedRequest.peek(url, {file, documentPath, documentFormat}).then(({data: {operations, stats}}) => {
      return revisions.map(revision => this._mapOperations(revision, operations, stats));
    });
  },

  merge({revision, project, file, mergeType, documentPath, documentFormat}) {
    const url = fmt(config.API.MERGE_PEEK_PROJECT_PATH, project.id, revision.language.slug, mergeType);
    documentFormat = documentFormat.toLowerCase();

    return this.authenticatedRequest
      .peek(url, {file, documentPath, documentFormat})
      .then(({data: {operations, stats}}) => [this._mapOperations(revision, operations, stats)]);
  },

  _mapOperations(revision, operations, stats) {
    return EmberObject.create({
      language: revision.language,
      stats: this._mapOperationStats(stats[revision.id]),
      operations: this._mapOperationItems(operations[revision.id])
    });
  },

  _mapOperationStats(stats) {
    if (!stats) return [];

    return Object.keys(stats).map(action => {
      const count = stats[action];

      return EmberObject.create({action, count});
    });
  },

  _mapOperationItems(operations) {
    if (!operations) return [];

    return operations.map(operation => {
      return EmberObject.create({
        action: operation.action,
        key: operation.key,
        text: operation.text,
        previousText: operation['previous-text']
      });
    });
  }
});
