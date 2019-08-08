import {computed} from '@ember/object';
import Component from '@ember/component';

// Attributes:
// collaborators: Array of <collaborator>
// permissions: Ember Object containing <permission>
// onDelete: Function
// onUpdate: Function
export default Component.extend({
  filteredCollaborators: computed('collaborators.[]', function() {
    return this.collaborators.filter(
      collaborator => collaborator.isPending || !collaborator.user.isBot
    );
  }),

  actions: {
    deleteCollaborator(collaborator) {
      return this.onDelete(collaborator);
    },

    updateCollaborator(collaborator, args) {
      return this.onUpdate(collaborator, args);
    }
  }
});
