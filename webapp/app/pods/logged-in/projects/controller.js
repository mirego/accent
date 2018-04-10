import {inject as service} from '@ember/service';
import {equal, and, readOnly} from '@ember/object/computed';
import Controller from '@ember/controller';

export default Controller.extend({
  globalState: service('global-state'),
  session: service('session'),

  queryParams: ['query', 'page'],

  query: '',
  page: 1,

  permissions: readOnly('model.permissions'),
  emptyEntries: equal('model.projects.entries', undefined),
  showLoading: and('emptyEntries', 'model.loading'),

  actions: {
    changeQuery(query) {
      this.set('query', query);
    },

    selectPage(page) {
      window.scrollTo(0, 0);
      this.set('page', page);
    }
  }
});
