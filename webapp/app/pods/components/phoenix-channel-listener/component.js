import {inject as service} from '@ember/service';
import Component from '@ember/component';

export default Component.extend({
  session: service(),
  phoenix: service(),

  init() {
    this._super(...arguments);

    if (!this.session.credentials.token || !this.project) return;

    const phoenixService = this.phoenix;
    const token = `Bearer ${this.session.credentials.token}`;

    phoenixService
      .getChannel(`projects:${this.project.id}`, {token})
      .then(phoenixService.joinChannel)
      .then(channel =>
        phoenixService.bindChannelEvents(
          channel,
          this.session.credentials.user.id
        )
      )
      .then(channel => this.set('channel', channel));
  },

  willDestroyElement() {
    this._super(...arguments);
    this.phoenix.leaveChannel(this.channel);
  }
});
