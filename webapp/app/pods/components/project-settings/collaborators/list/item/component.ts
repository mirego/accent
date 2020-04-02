import {action} from '@ember/object';
import {notEmpty} from '@ember/object/computed';
import {inject as service} from '@ember/service';
import Component from '@glimmer/component';
import Session from 'accent-webapp/services/session';
import IntlService from 'ember-intl/services/intl';
import {tracked} from '@glimmer/tracking';
import GlobalState from 'accent-webapp/services/global-state';

interface Args {
  permissions: Record<string, true>;
  collaborator: any;
  onDelete: (collaborator: any) => void;
  onUpdate: (collaborator: any, args: any) => Promise<void>;
}

export default class CollaboratorsListItem extends Component<Args> {
  @service('session')
  session: Session;

  @service('intl')
  intl: IntlService;

  @service('global-state')
  globalState: GlobalState;

  @tracked
  isEditing = false;

  @tracked
  updatedRole = this.args.collaborator.role;

  @notEmpty('args.collaborator.user.id')
  hasJoined: boolean;

  get possibleRoles() {
    return this.globalState.roles.map(({slug}: {slug: string}) => slug);
  }

  get mappedPossibleRoles() {
    return this.possibleRoles.map((value) => ({
      label: this.intl.t(`general.roles.${value}`),
      value,
    }));
  }

  get roleValue() {
    return this.mappedPossibleRoles.find(({value}) => {
      return value === this.updatedRole;
    });
  }

  get canDeleteCollaborator() {
    return (
      this.args.permissions &&
      this.args.permissions.create_collaborator &&
      (!this.args.collaborator.user ||
        (this.args.collaborator.user &&
          this.session.credentials.user.id !== this.args.collaborator.user.id))
    );
  }

  get canUpdateCollaborator() {
    return (
      this.args.permissions &&
      this.args.permissions.update_collaborator &&
      this.args.collaborator.user &&
      this.session.credentials.user.id !== this.args.collaborator.user.id
    );
  }

  get role() {
    return this.intl.t(`general.roles.${this.args.collaborator.role}`);
  }

  @action
  setRole({value}: {value: string}) {
    this.updatedRole = value;
  }

  @action
  deleteCollaborator() {
    this.args.onDelete(this.args.collaborator);
  }

  @action
  async updateCollaborator() {
    await this.args.onUpdate(this.args.collaborator, {role: this.updatedRole});

    this.isEditing = false;
  }

  @action
  toggleUpdateCollaborator() {
    this.updatedRole = this.args.collaborator.role;
    this.isEditing = !this.isEditing;
  }
}
