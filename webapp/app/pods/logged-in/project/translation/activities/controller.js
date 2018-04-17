import {inject as service} from '@ember/service';
import {readOnly, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';

export default Controller.extend({
  globalState: service('global-state'),

  queryParams: ['page'],

  page: 1,

  permissions: readOnly('globalState.permissions'),
  emptyEntries: equal('model.activities.entries', undefined),
  showSkeleton: and('emptyEntries', 'model.loading'),

  actions: {
    selectPage(page) {
      window.scroll(0, 0);
      this.set('page', page);
    }
  }
});
