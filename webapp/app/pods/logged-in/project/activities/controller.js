import {inject as service} from '@ember/service';
import {readOnly, not, and} from '@ember/object/computed';
import Controller from '@ember/controller';

export default Controller.extend({
  i18n: service(),
  flashMessages: service(),
  apolloMutate: service('apollo-mutate'),
  globalState: service('global-state'),

  queryParams: ['batchFilter', 'actionFilter', 'userFilter', 'page'],

  batchFilter: null,
  actionFilter: null,
  userFilter: null,
  page: 1,

  permissions: readOnly('globalState.permissions'),
  emptyEntries: not('model.activities', undefined),
  showSkeleton: and('emptyEntries', 'model.loading'),

  actions: {
    batchFilterChange(checked) {
      this.set('batchFilter', checked ? true : null);
      this.set('page', 1);
    },

    actionFilterChange(action) {
      this.set('actionFilter', action);
      this.set('page', 1);
    },

    userFilterChange(user) {
      this.set('userFilter', user);
      this.set('page', 1);
    },

    selectPage(page) {
      window.scroll(0, 0);
      this.set('page', page);
    }
  }
});
