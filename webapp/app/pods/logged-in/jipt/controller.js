import {inject as service} from '@ember/service';
import {observer} from '@ember/object';
import Controller from '@ember/controller';
import {readOnly} from '@ember/object/computed';

export default Controller.extend({
  jipt: service('jipt'),
  router: service('router'),
  globalState: service('global-state'),

  queryParams: ['revisionId'],

  init() {
    window.addEventListener(
      'message',
      payload => {
        if (payload.data.jipt && payload.data.selectId) {
          this.router.transitionTo('logged-in.jipt.translation', payload.data.selectId);
        }
        if (payload.data.jipt && payload.data.selectIds) {
          this.router.transitionTo('logged-in.jipt.index', {queryParams: {translationIds: payload.data.selectIds}});
        }
      },
      false
    );
  },

  revision: readOnly('model.project.revision'),
  revisions: readOnly('model.project.revisions'),

  translationsObserver: observer('model.project.revision.translations.entries', function() {
    if (!this.model.project) return;

    this.jipt.listTranslations(this.model.project.revision.translations.entries, this.model.project.revision);
  }),

  permissionsObserver: observer('model.permissions', function() {
    this.globalState.set('permissions', this.model.permissions);
  }),

  actions: {
    selectRevision(revisionId) {
      this.set('revisionId', revisionId);
    }
  }
});
