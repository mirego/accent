import Service, {service} from '@ember/service';
import {Socket, Channel} from 'accent-webapp/utils/phoenix';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';

interface WebsocketMessageUser {
  id: string;
  name: string;
}

interface WebsocketMessagePayloadUser {
  email: string;
}

interface WebsocketMessagePayloadCollaborator {
  email: string;
}

interface WebsocketMessagePayloadTranslation {
  id: string;
  key: string;
}

interface WebsocketMessagePayload {
  user?: WebsocketMessagePayloadUser;
  collaborator?: WebsocketMessagePayloadCollaborator;
  translation?: WebsocketMessagePayloadTranslation;
  text?: string;
  /* eslint-disable camelcase */
  document_path?: string;
  /* eslint-enable camelcase */
}

interface WebsocketMessage {
  payload: WebsocketMessagePayload;
  user: WebsocketMessageUser;
}

export default class Phoenix extends Service {
  @service('intl')
  declare intl: IntlService;

  @service('flash-messages')
  declare flashMessages: FlashMessages;

  socket({token}: {token: string}) {
    const socket = new Socket('/socket', {
      params: {token}
    });

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
      create_comment: this.handleCreateComment
    };
    /* eslint-enable camelcase */

    Object.keys(events).forEach((eventId: keyof typeof events) => {
      channel.on(eventId, (message: WebsocketMessage) => {
        if (message.user?.id === currentUserId) return;

        events[eventId].bind(this)(message);
      });
    });

    return channel;
  }

  private handleSync({payload, user}: WebsocketMessage) {
    /* eslint camelcase:0 */
    this.showFlashMessage('sync', {
      user: user.name,
      documentPath: payload.document_path
    });
    /* eslint camelcase:1 */
  }

  private handleCreateCollaborator({payload, user}: WebsocketMessage) {
    this.showFlashMessage('create_collaborator', {
      user: user.name,
      collaboratorEmail: payload?.collaborator?.email
    });
  }

  private handleCreateComment({payload, user}: WebsocketMessage) {
    this.showFlashMessage('create_comment', {
      user: user.name,
      commentText: payload.text,
      translationKey: payload?.translation?.key
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
