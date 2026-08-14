import {action} from '@ember/object';
import {service} from '@ember/service';
import Component from '@glimmer/component';
import Session from 'accent-webapp/services/session';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';

interface Args {
  collaborator: any;
  subscriptions: any;
  onCreateSubscription: (user: any) => Promise<void>;
  onDeleteSubscription: (subscription: any) => Promise<void>;
}

export default class TranslationCommentsSubscriptionsItem extends Component<Args> {
  <template>
    <li
      class='translation-comments-subscriptions-item
        {{if this.isCurrentUser "currentUser"}}'
    >
      <input
        type='checkbox'
        checked={{this.isSubscribed}}
        class='checkbox'
        {{on 'change' (fn this.toggleSubscription)}}
      />

      <span class='user'>
        {{@collaborator.user.fullname}}

        <span class='user-email'>
          {{@collaborator.email}}
        </span>
      </span>
    </li>

    <style scoped>
      .translation-comments-subscriptions-item {
        display: flex;
        align-items: flex-start;
        margin: 0 0 10px;
        font-size: 13px;
        color: #888;
        transition: 0.2s ease-in-out;
        transition-property: color;
      }
      .translation-comments-subscriptions-item:last-child {
        margin: 0;
      }

      .translation-comments-subscriptions-item.currentUser {
        font-weight: bold;
        color: #444;
      }

      .user {
        margin-left: 7px;
      }

      .user-email {
        font-size: 12px;
        font-weight: normal;
        font-style: italic;
        color: #777;
      }

      .checkbox {
        display: block;
        flex-shrink: 0;
        margin-top: 3px;
        cursor: pointer;
      }
    </style>
  </template>
  @service('session')
  declare session: Session;

  get currentUser() {
    return this.session.credentials.user;
  }

  get isSubscribed() {
    return Boolean(this.subscription);
  }

  get isCurrentUser() {
    return this.currentUser?.id === this.args.collaborator.user.id;
  }

  get subscription() {
    return this.args.subscriptions.find((subscription: any) => {
      return subscription.user.id === this.args.collaborator.user.id;
    });
  }

  @action
  async toggleSubscription() {
    if (this.isSubscribed) {
      await this.args.onDeleteSubscription(this.subscription);
    } else {
      await this.args.onCreateSubscription(this.args.collaborator.user);
    }
  }
}
