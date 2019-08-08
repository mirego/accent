import {computed} from '@ember/object';
import {notEmpty, map, reads} from '@ember/object/computed';
import {inject as service} from '@ember/service';
import Component from '@ember/component';

// Attributes:
// collaborator: Object <collaborator>
// permissions: Ember Object containing <permission>
// onDelete: Function
// onUpdate: Function
export default Component.extend({
  tagName: 'li',
  classNameBindings: [
    'hasJoined:joined:invited',
    'collaborator.user.pictureUrl:withPicture'
  ],

  session: service('session'),
  i18n: service('i18n'),
  globalState: service('global-state'),

  isEditing: false,

  hasJoined: notEmpty('collaborator.user.id'),

  possibleRoles: map('globalState.roles', ({slug}) => slug),
  mappedPossibleRoles: map('possibleRoles', value => ({
    label: `general.roles.${value}`,
    value
  })),

  updatedRole: reads('collaborator.role'),

  roleValue: computed('updatedRole', 'mappedPossibleRoles.[]', function() {
    return this.mappedPossibleRoles.find(
      ({value}) => value === this.updatedRole
    );
  }),

  canDeleteCollaborator: computed(
    'permissions',
    'session.credentials.user.id',
    'collaborator.user.id',
    function() {
      return (
        this.permissions &&
        this.permissions.create_collaborator &&
        (!this.collaborator.user ||
          (this.collaborator.user &&
            this.session.credentials.user.id !== this.collaborator.user.id))
      );
    }
  ),

  canUpdateCollaborator: computed(
    'permissions',
    'session.credentials.user.id',
    'collaborator.user.id',
    function() {
      return (
        this.permissions &&
        this.permissions.update_collaborator &&
        this.collaborator.user &&
        this.session.credentials.user.id !== this.collaborator.user.id
      );
    }
  ),

  role: computed('collaborator.role', function() {
    return this.i18n.t(`general.roles.${this.collaborator.role}`);
  }),

  actions: {
    deleteCollaborator() {
      this.onDelete(this.collaborator);
    },

    updateCollaborator() {
      this.onUpdate(this.collaborator, {role: this.updatedRole}).then(() =>
        this.set('isEditing', false)
      );
    },

    toggleUpdateCollaborator() {
      this.setProperties({
        updatedRole: this.collaborator.role,
        isEditing: !this.isEditing
      });
    }
  }
});
