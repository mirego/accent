import {computed} from '@ember/object';
import {inject as service} from '@ember/service';
import Component from '@ember/component';

const ACTIONS_PREFIX = 'components.project_activities_filter.actions.';

// Attributes:
// collaborators: Array of <collaborator>
// batchFilter: Boolean
// actionFilter: String
// batchFilterChange: Function
// actionFilterChange: Function
// userFilterChange: Function
export default Component.extend({
  intl: service('intl'),

  keys: [
    'new',
    'renew',
    'remove',
    'update',
    'sync',
    'merge',
    'rollback',
    'correct_conflict',
    'uncorrect_conflict',
    'correct_all',
    'uncorrect_all',
    'conflict_on_proposed',
    'conflict_on_corrected',
    'conflict_on_slave',
    'document_delete'
  ],

  mappedActions: computed('keys', function() {
    const actions = this.keys.map(key => {
      return {
        value: key,
        label: `${ACTIONS_PREFIX}${key}`
      };
    });

    actions.unshift({
      label: 'components.project_activities_filter.actions_default_option_text',
      value: null
    });

    return actions;
  }),

  mappedUsers: computed('collaborators.[]', function() {
    const users = this.collaborators
      .filter(collaborator => !collaborator.isPending)
      .map(({user: {fullname, id}}) => ({label: fullname, value: id}));

    users.unshift({
      label: this.intl.t(
        'components.project_activities_filter.collaborators_default_option_text'
      ),
      value: null
    });

    return users;
  }),

  actionFilterValue: computed('actionFilter', 'mappedActions.[]', function() {
    return this.mappedActions.find(({value}) => value === this.actionFilter);
  }),

  userFilterValue: computed('userFilter', 'mappedUsers.[]', function() {
    return this.mappedUsers.find(({value}) => value === this.userFilter);
  }),

  actions: {
    batchFilterChange(event) {
      this.batchFilterChange(!!event.target.checked);
    },

    actionFilterChange(action) {
      this.batchFilterChange(false);
      this.actionFilterChange(action);
    },

    userFilterChange(user) {
      this.userFilterChange(user);
    }
  }
});
