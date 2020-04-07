import Service, {inject as service} from '@ember/service';
import config from 'accent-webapp/config/environment';
import {Socket, Channel} from 'accent-webapp/utils/phoenix';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';

export default class Phoenix extends Service {
  @service('intl')
  intl: IntlService;

  @service('flash-messages')
  flashMessages: FlashMessages;

  socket({token}: {token: string}) {
    const socket = new Socket(`${config.API.WS_HOST}/socket`, {
      params: {token},
    });

    // eslint-disable-next-line @typescript-eslint/ban-ts-ignore
    // @ts-ignore
    socket.connect();

    return socket;
  }

  leaveChannel(channel: Channel) {
    if (channel) return channel.leave();

    return;
  }

  // eslint-disable-next-line @typescript-eslint/require-await
  async getChannel(channelName: string, {token}: {token: string}) {
    const socket = this.socket({token});

    return socket.channel(channelName);
  }

  async joinChannel(channel: Channel) {
    return new Promise((resolve, reject) => {
      channel
        .join()
        .receive('ok', () => resolve(channel))
        .receive('error', (reason: any) => reject(reason));
    });
  }

  // eslint-disable-next-line @typescript-eslint/require-await
  async bindChannelEvents(channel: Channel, currentUserId: string) {
    /* eslint-disable camelcase */
    const events = {
      sync: this.handleSync,
      create_collaborator: this.handleCreateCollaborator,
      create_comment: this.handleCreateComment,
    };
    /* eslint-enable camelcase */

    Object.keys(events).forEach((eventId: keyof typeof events) => {
      channel.on(eventId, (payload: any) =>
        this.handleEvent(events[eventId].bind(this), {
          payload,
          currentUserId,
        })
      );
    });

    return channel;
  }

  private handleEvent(
    func: ({payload}: {payload: any}) => any,
    {payload, currentUserId}: {payload: any; currentUserId: string}
  ) {
    if (payload.user && payload.user.id !== currentUserId) {
      return func({payload});
    }
  }

  private handleSync({payload}: {payload: any}) {
    /* eslint camelcase:0 */
    this.showFlashMessage('sync', {
      user: payload.user.name,
      documentPath: payload.document_path,
    });
    /* eslint camelcase:1 */
  }

  private handleCreateCollaborator({payload}: {payload: any}) {
    this.showFlashMessage('create_collaborator', {
      user: payload.user.name,
      collaboratorEmail: payload.collaborator.email,
    });
  }

  private handleCreateComment({payload}: {payload: any}) {
    this.showFlashMessage('create_comment', {
      user: payload.user.name,
      commentText: payload.comment.text,
      translationKey: payload.comment.translation.key,
    });
  }

  private showFlashMessage(
    event: 'sync' | 'create_collaborator' | 'create_comment',
    options: {
      user: any;
      documentPath?: string;
      collaboratorEmail?: string;
      commentText?: string;
      translationKey?: string;
    }
  ) {
    this.flashMessages.socket(
      this.intl.t(`addon.channel.handle_in.${event}`, options)
    );
  }
}

declare module '@ember/service' {
  interface Registry {
    phoenix: Phoenix;
  }
}
