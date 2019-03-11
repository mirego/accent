import {inject as service} from '@ember/service';
import {computed} from '@ember/object';
import {not, map} from '@ember/object/computed';
import Component from '@ember/component';

// Attributes:
// project: Object <project>
// onCreate: Function
export default Component.extend({
  globalState: service('global-state'),

  isCreating: false,
  email: '',
  emptyEmail: not('email'),

  possibleRoles: map('globalState.roles', ({slug}) => slug),
  mappedPossibleRoles: map('possibleRoles', value => ({
    label: `general.roles.${value}`,
    value
  })),

  roleValue: computed('role', 'mappedPossibleRoles.[]', function() {
    return this.mappedPossibleRoles.find(({value}) => value === this.role);
  }),

  role: computed('possibleRoles.[]', function() {
    return this.possibleRoles[0];
  }),

  actions: {
    selectRole(value) {
      this.set('role', value);
    },

    submit() {
      this.set('isCreating', true);

      this.onCreate(this.getProperties('email', 'role'))
        .then(() => this.setProperties({email: ''}))
        .then(() => this.set('isCreating', false));
    }
  }
});
