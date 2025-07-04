import {action} from '@ember/object';
import {service} from '@ember/service';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';

const ACTIONS_PREFIX = 'components.project_activities_filter.actions.';

interface Args {
  versions: any;
  collaborators: any;
  batchFilter: any;
  actionFilter: any;
  userFilter: any;
  versionFilter: any;
  userFilterChange: (user: any) => void;
  batchFilterChange: (checked: boolean) => void;
  actionFilterChange: (actionFilter: any) => void;
  versionFilterChange: (versionFilter: any) => void;
}

export default class ProjectActivitiesFilter extends Component<Args> {
  @service('intl')
  declare intl: IntlService;

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
    'document_delete'
  ];

  get mappedActions() {
    const actions: Array<{value: string | null; label: string}> = this.keys.map(
      (key) => {
        return {
          value: key,
          label: this.intl.t(`${ACTIONS_PREFIX}${key}`)
        };
      }
    );

    actions.unshift({
      label: this.intl.t(
        'components.project_activities_filter.actions_default_option_text'
      ),
      value: ''
    });

    return actions;
  }

  get mappedUsers() {
    if (!this.args.collaborators) return [];

    const users = this.args.collaborators
      .filter((collaborator: any) => !collaborator.isPending)
      .map(({user: {fullname, id}}: {user: any}) => ({
        label: fullname,
        value: id
      }));

    users.unshift({
      label: this.intl.t(
        'components.project_activities_filter.collaborators_default_option_text'
      ),
      value: ''
    });

    return users;
  }

  get mappedVersions() {
    if (!this.args.versions) return [];

    const versions = this.args.versions.map(
      ({tag, id}: {tag: string; id: string}) => ({
        label: tag,
        value: id
      })
    );

    versions.unshift({
      label: this.intl.t(
        'components.project_activities_filter.versions_default_option_text'
      ),
      value: ''
    });

    return versions;
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

  get versionFilterValue() {
    return this.mappedVersions.find(
      ({value}: {value: any}) => value === this.args.versionFilter
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

  @action
  versionFilterChange(version: any) {
    this.args.versionFilterChange(version.value);
  }
}
