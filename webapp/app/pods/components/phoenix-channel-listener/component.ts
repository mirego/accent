// Vendor
import {inject as service} from '@ember/service';
import Component from '@glimmer/component';
import {action} from '@ember/object';
import Session from 'accent-webapp/services/session';
import Phoenix from 'accent-webapp/services/phoenix';
import {Channel} from 'accent-webapp/utils/phoenix';

// Config
import config from 'accent-webapp/config/environment';

interface Args {
  project: any;
}

export default class PhoenixChannelListener extends Component<Args> {
  @service('session')
  session: Session;

  @service('phoenix')
  phoenix: Phoenix;

  channel: Channel;

  wsEnabled = config.API.WS_ENABLED;

  @action
  joinChannel() {
    if (!this.session.credentials.token || !this.args.project) return;

    const phoenixService = this.phoenix;
    const token = `Bearer ${this.session.credentials.token}`;

    // eslint-disable-next-line @typescript-eslint/no-floating-promises
    phoenixService
      .getChannel(`projects:${this.args.project.id}`, {token})
      .then(phoenixService.joinChannel)
      .then(async (channel: Channel) =>
        phoenixService.bindChannelEvents(
          channel,
          this.session.credentials.user.id
        )
      )
      .then((channel) => (this.channel = channel));
  }

  @action
  leaveChannel() {
    this.phoenix.leaveChannel(this.channel);
  }
}
