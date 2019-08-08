import Service, {inject as service} from '@ember/service';
import RSVP from 'rsvp';
import config from 'accent-webapp/config/environment';
import {Socket} from 'accent-webapp/utils/phoenix';

export default Service.extend({
  i18n: service(),
  flashMessages: service(),

  socket({token}) {
    const socket = new Socket(`${config.API.WS_HOST}/socket`, {
      params: {token}
    });

    socket.connect();
    return socket;
  },

  leaveChannel(channel) {
    if (channel) return channel.leave();
  },

  getChannel(channelName, {token}) {
    return new RSVP.Promise(resolve => {
      const socket = this.socket({token});

      resolve(socket.channel(channelName));
    });
  },

  joinChannel(channel) {
    return new RSVP.Promise((resolve, reject) => {
      channel
        .join()
        .receive('ok', () => resolve(channel))
        .receive('error', reason => reject(reason));
    });
  },

  bindChannelEvents(channel, currentUserId) {
    return new RSVP.Promise(resolve => {
      /* eslint-disable camelcase */
      const events = {
        sync: this._handleSync,
        create_collaborator: this._handleCreateCollaborator,
        create_comment: this._handleCreateComment
      };
      /* eslint-enable camelcase */

      Object.keys(events).forEach(eventId => {
        channel.on(eventId, payload =>
          this._handleEvent(events[eventId].bind(this), {
            payload,
            currentUserId
          })
        );
      });

      resolve(channel);
    });
  },

  _handleEvent(func, {payload, currentUserId}) {
    if (payload.user && payload.user.id !== currentUserId)
      return func({payload});
  },

  _handleSync({payload}) {
    /* eslint camelcase:0 */
    this._showFlashMessage('sync', {
      user: payload.user.name,
      documentPath: payload.document_path
    });
    /* eslint camelcase:1 */
  },

  _handleCreateCollaborator({payload}) {
    this._showFlashMessage('create_collaborator', {
      user: payload.user.name,
      collaboratorEmail: payload.collaborator.email
    });
  },

  _handleCreateComment({payload}) {
    this._showFlashMessage('create_comment', {
      user: payload.user.name,
      commentText: payload.comment.text,
      translationKey: payload.comment.translation.key
    });
  },

  _showFlashMessage(event, options) {
    this.flashMessages.socket(
      this.i18n.t(`addon.channel.handle_in.${event}`, options)
    );
  }
});
