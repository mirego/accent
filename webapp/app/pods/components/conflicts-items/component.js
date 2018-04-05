import Component from '@ember/component';
import {computed} from '@ember/object';

// Attributes:
// project: Object <project>
// permissions: Ember Object containing <permission>
// conflicts: Array of <conflict>
// referenceRevision: Object <revision> (optional)
// fullscreen: Boolean
// query: String
// onCorrect: Function
// onCorrectAll: Function
export default Component.extend({
  classNameBindings: ['fullscreen'],
  tagName: 'ul',

  isCorrectAllConflictLoading: false,

  toggledFullscreen: computed('fullscreen', function() {
    return !this.fullscreen;
  }),

  actions: {
    correctAllConflicts() {
      this.set('isCorrectAllConflictLoading', true);

      this.onCorrectAll().then(() => {
        this.set('isCorrectAllConflictLoading', false);
      });
    }
  }
});
