import {inject as service} from '@ember/service';
import Component from '@glimmer/component';
import {action} from '@ember/object';
import Session from 'accent-webapp/services/session';
import {tracked} from '@glimmer/tracking';

interface Args {
  onDummyLogin: (email: string) => void;
}

export default class DummyLoginForm extends Component<Args> {
  @service('session')
  session: Session;

  @tracked
  email = '';

  @action
  setEmail(event: Event) {
    const target = event.target as HTMLInputElement;

    this.email = target.value;
  }

  @action
  submit() {
    this.args.onDummyLogin(this.email);
  }
}
