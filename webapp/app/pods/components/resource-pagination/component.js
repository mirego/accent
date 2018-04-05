import {or, readOnly, not} from '@ember/object/computed';
import Component from '@ember/component';

// Attributes:
// meta: Object containing meta infos from a model
// onSelectPage: Function
export default Component.extend({
  showPagination: or('meta.{nextPage,previousPage}'),

  hasPrevious: readOnly('meta.previousPage'),
  hasNext: readOnly('meta.nextPage'),
  disabledPrevious: not('hasPrevious'),
  disabledNext: not('hasNext'),

  actions: {
    goToNextPage() {
      if (!this.meta.nextPage) return;
      this.onSelectPage(this.meta.nextPage);
    },

    goToPreviousPage() {
      if (!this.meta.previousPage) return;
      this.onSelectPage(this.meta.previousPage);
    }
  }
});
