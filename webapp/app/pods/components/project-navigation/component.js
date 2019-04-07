import {computed} from '@ember/object';
import {inject as service} from '@ember/service';
import {reads} from '@ember/object/computed';
import Component from '@ember/component';

// Attributes:
// project: Object <project>
// permissions: Ember Object containing <permission>
export default Component.extend({
  globalState: service('global-state'),

  isListShowing: reads('globalState.isProjectNavigationListShowing'),

  selectedRevision: computed(
    'globalState.revision',
    'revisions.[]',
    function() {
      const selected = this.globalState.revision;

      if (selected && this.revisions.map(({id}) => id).includes(selected)) {
        return selected;
      }

      if (!this.revisions) return;
      return this.revisions[0].id;
    }
  )
});
