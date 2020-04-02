import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';

const ACTIONS_PREFIX = 'components.project_activities_filter.actions.';

interface Args {
  collaborators: any;
  batchFilter: any;
  actionFilter: any;
  userFilter: any;
  userFilterChange: (user: any) => void;
  batchFilterChange: (checked: boolean) => void;
  actionFilterChange: (actionFilter: any) => void;
}

export default class ProjectActivitiesFilter extends Component<Args> {
  @service('intl')
  intl: IntlService;

  keys = [
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
    'document_delete',
  ];

  get mappedActions() {
    const actions: Array<{value: string | null; label: string}> = this.keys.map(
      (key) => {
        return {
          value: key,
          label: this.intl.t(`${ACTIONS_PREFIX}${key}`),
        };
      }
    );

    actions.unshift({
      label: this.intl.t(
        'components.project_activities_filter.actions_default_option_text'
      ),
      value: null,
    });

    return actions;
  }

  get mappedUsers() {
    if (!this.args.collaborators) return [];

    const users = this.args.collaborators
      .filter((collaborator: any) => !collaborator.isPending)
      .map(({user: {fullname, id}}: {user: any}) => ({
        label: fullname,
        value: id,
      }));

    users.unshift({
      label: this.intl.t(
        'components.project_activities_filter.collaborators_default_option_text'
      ),
      value: null,
    });

    return users;
  }

  get actionFilterValue() {
    return this.mappedActions.find(
      ({value}) => value === this.args.actionFilter
    );
  }

  get userFilterValue() {
    return this.mappedUsers.find(
      ({value}: {value: any}) => value === this.args.userFilter
    );
  }

  @action
  batchFilterChange(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.batchFilterChange(!!target.checked);
  }

  @action
  actionFilterChange(actionFilter: any) {
    this.args.batchFilterChange(false);
    this.args.actionFilterChange(actionFilter.value);
  }

  @action
  userFilterChange(user: any) {
    this.args.userFilterChange(user.value);
  }
}
