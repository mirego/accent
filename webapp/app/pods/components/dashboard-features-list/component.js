import {computed} from '@ember/object';
import Component from '@ember/component';

// Attributes:
// project: Object <project>
// revision: Object <revision>
// permissions: Ember Object containing <permission>
export default Component.extend({
  highlightSync: computed('revision.translationsCount', function() {
    return this.revision.translationsCount <= 0;
  }),

  highlightReview: computed('highlightSync', 'permissions.sync', function() {
    return !this.highlightSync && this.revision.conflictsCount > 0;
  })
});
