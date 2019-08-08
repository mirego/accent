import {computed} from '@ember/object';
import Component from '@ember/component';

// Attributes
// subscriptions: Array of <translation-comments-subscription>
// collaborators: Array of <collaborator>
// onCreateSubscription: Function
// onDeleteSubscription: Function
export default Component.extend({
  tagName: 'ul',

  filteredCollaborators: computed('collaborators', function() {
    return this.collaborators
      .filter(collaborator => !collaborator.isPending)
      .filter(collaborator => collaborator.role !== 'BOT');
  })
});
