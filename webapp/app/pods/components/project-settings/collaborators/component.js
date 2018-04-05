import Component from '@ember/component';

// Attributes
// project: Object <project>
// permissions: Ember Object containing <permission>
// collaborators: Array of <collaborator>
// onDeleteCollaborator: Function
// onUpdateCollaborator: Function
// onCreateCollaborator: Function
export default Component.extend({
  showCreateForm: false,

  actions: {
    toggleCreateForm() {
      this.set('showCreateForm', !this.showCreateForm);
    }
  }
});
