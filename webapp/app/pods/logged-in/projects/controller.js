import {inject as service} from '@ember/service';
import {equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';

export default Controller.extend({
  session: service('session'),

  queryParams: ['query', 'page'],

  query: '',
  page: 1,

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
