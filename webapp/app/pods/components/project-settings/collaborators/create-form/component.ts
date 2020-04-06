import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {not} from '@ember/object/computed';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';

interface Args {
  project: any;
  onCancel: () => void;
  onCreate: ({email, role}: {email: string; role: string}) => Promise<void>;
}

export default class CreateForm extends Component<Args> {
  @service('intl')
  intl: IntlService;

  @service('global-state')
  globalState: GlobalState;

  @tracked
  isCreating = false;

  @tracked
  email = '';

  @tracked
  role = this.possibleRoles[0];

  @not('email')
  emptyEmail: boolean;

  get possibleRoles() {
    return this.globalState.roles.map(({slug}: {slug: string}) => slug);
  }

  get mappedPossibleRoles() {
    return this.possibleRoles.map(value => ({
      label: this.intl.t(`general.roles.${value}`),
      value
    }));
  }

  get roleValue() {
    return this.mappedPossibleRoles.find(({value}) => value === this.role);
  }

  @action
  setRole({value}: {value: string}) {
    this.role = value;
  }

  @action
  async submit() {
    this.isCreating = true;

    await this.args.onCreate({email: this.email, role: this.role});
    this.email = '';
    this.isCreating = false;
  }
}
