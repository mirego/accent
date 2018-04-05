import {computed} from '@ember/object';
import {inject as service} from '@ember/service';
import {reads, bool} from '@ember/object/computed';
import Component from '@ember/component';

// Attributes:
// collaborator: Object <collaborator>
// subscriptions: Array of <translation-comments-subscription>
// onCreateSubscription: Function
// onDeleteSubscription: Function
export default Component.extend({
  classNameBindings: ['isCurrentUser:currentUser'],
  tagName: 'li',

  session: service('session'),
  currentUser: reads('session.credentials.user'),

  isCurrentUser: computed('currentUser.id', 'collaborator.user.id', function() {
    return this.currentUser.id === this.collaborator.user.id;
  }),

  isSubscribed: bool('subscription'),

  subscription: computed('subscriptions.[]', 'collaborator.user.id', function() {
    return this.subscriptions.find(subscription => subscription.user.id === this.collaborator.user.id);
  }),

  click() {
    if (this.isSubscribed) {
      this.onDeleteSubscription(this.subscription);
    } else {
      this.onCreateSubscription(this.collaborator.user);
    }
  }
});
