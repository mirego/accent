import Component from '@glimmer/component';
import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import {dropTask} from 'ember-concurrency';
import {taskFor} from 'ember-concurrency-ts';
import IntlService from 'ember-intl/services/intl';

interface Args {
  token: any;
  onRevoke: (args: {id: string}) => void;
}

export default class APITokenItem extends Component<Args> {
  @service('intl')
  intl: IntlService;

  @tracked
  showPermissions = false;

  get isRevoking() {
    return taskFor(this.revokeTask).isRunning;
  }

  @dropTask
  *revokeTask() {
    const message = this.intl.t(
      'components.project_settings.api_token.revoke_confirm'
    );

    // eslint-disable-next-line no-alert
    if (!window.confirm(message)) {
      return;
    }

    yield this.args.onRevoke(this.args.token);
  }

  @action
  togglePermissions() {
    this.showPermissions = !this.showPermissions;
  }
}
