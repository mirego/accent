import {inject as service} from '@ember/service';
import {observer, computed} from '@ember/object';
import {reads} from '@ember/object/computed';
import Component from '@ember/component';

// Attributes
// project: Object <project>
// permissions: Ember Object containing <permission>
// onUpdateProject: Function
export default Component.extend({
  globalState: service('global-state'),

  name: reads('project.name'),
  mainColor: reads('project.mainColor'),
  isFileOperationsLocked: reads('project.isFileOperationsLocked'),

  d: observer('mainColor', function() {
    this.globalState.set('mainColor', this.mainColor);
  }),

  unchangedForm: computed('project', 'mainColor', 'name', function() {
    return (
      this.mainColor === this.project.mainColor &&
      this.name === this.project.name
    );
  }),

  actions: {
    setLockedFileOperations() {
      this.toggleProperty('isFileOperationsLocked');
      this.onUpdateProject(
        this.getProperties('isFileOperationsLocked', 'name', 'mainColor')
      );
    },

    updateProject() {
      this.onUpdateProject(
        this.getProperties('isFileOperationsLocked', 'name', 'mainColor')
      );
    }
  }
});
