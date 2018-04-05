import {reads} from '@ember/object/computed';
import Component from '@ember/component';

// Attributes
// project: Object <project>
// permissions: Ember Object containing <permission>
// onUpdateProject: Function
export default Component.extend({
  name: reads('project.name'),
  isFileOperationsLocked: reads('project.isFileOperationsLocked'),

  actions: {
    setLockedFileOperations() {
      this.toggleProperty('isFileOperationsLocked');
      this.onUpdateProject(this.getProperties('isFileOperationsLocked', 'name'));
    },

    updateProject() {
      this.onUpdateProject(this.getProperties('isFileOperationsLocked', 'name'));
    }
  }
});
