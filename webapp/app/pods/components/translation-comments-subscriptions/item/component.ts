import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {readOnly, bool} from '@ember/object/computed';
import Component from '@glimmer/component';
import Session from 'accent-webapp/services/session';

interface Args {
  collaborator: any;
  subscriptions: any;
  onCreateSubscription: (user: any) => Promise<void>;
  onDeleteSubscription: (subscription: any) => Promise<void>;
}

export default class TranslationCommentsSubscriptionsItem extends Component<
  Args
> {
  @service('session')
  session: Session;

  @readOnly('session.credentials.user')
  currentUser: any;

  @bool('subscription')
  isSubscribed: boolean;

  get isCurrentUser() {
    return this.currentUser.id === this.args.collaborator.user.id;
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
