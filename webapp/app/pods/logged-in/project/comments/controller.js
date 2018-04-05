import {equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';

export default Controller.extend({
  queryParams: ['page'],
  page: 1,

  emptyEntries: equal('model.comments.entries', undefined),
  showSkeleton: and('emptyEntries', 'model.loading'),

  actions: {
    selectPage(page) {
      window.scroll(0, 0);
      this.set('page', page);
    }
  }
});
