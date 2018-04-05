import {inject as service} from '@ember/service';
import {not, readOnly, and} from '@ember/object/computed';
import Controller from '@ember/controller';

export default Controller.extend({
  i18n: service(),
  flashMessages: service(),
  globalState: service('global-state'),

  page: 1,

  emptyEntries: not('model.versions', undefined),
  permissions: readOnly('globalState.permissions'),
  showSkeleton: and('emptyEntries', 'model.loading'),

  actions: {
    selectPage(page) {
      window.scroll(0, 0);
      this.set('page', page);
    }
  }
});
