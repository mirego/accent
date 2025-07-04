import Component from '@glimmer/component';
import {service} from '@ember/service';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import {dropTask} from 'ember-concurrency';
import IntlService from 'ember-intl/services/intl';

interface Args {
  token: any;
  onRevoke: (args: {id: string}) => Promise<void>;
}

export default class APITokenItem extends Component<Args> {
  @service('intl')
  declare intl: IntlService;

  @tracked
  showPermissions = false;

  get isRevoking() {
    return this.revokeTask.isRunning;
  }

  revokeTask = dropTask(async () => {
    const message = this.intl.t(
      'components.project_settings.api_token.revoke_confirm'
    );

    // eslint-disable-next-line no-alert
    if (!window.confirm(message)) {
      return;
    }

    await this.args.onRevoke(this.args.token);
  });

  @action
  togglePermissions() {
    this.showPermissions = !this.showPermissions;
  }
}
