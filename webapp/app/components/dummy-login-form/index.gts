import {service} from '@ember/service';
import Component from '@glimmer/component';
import {action} from '@ember/object';
import Session from 'accent-webapp/services/session';
import {tracked} from '@glimmer/tracking';
import t from 'ember-intl/helpers/t';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {scopedClass} from 'ember-scoped-css';

interface Args {
  onDummyLogin: (email: string) => void;
}

export default class DummyLoginForm extends Component<Args> {
  <template>
    <div class='dummy-login-form'>
      <h1 class='title'>
        {{t 'components.dummy_login_form.title'}}
      </h1>

      <div class='warning'>
        {{t 'components.dummy_login_form.warning'}}
      </div>

      <h2 class='subtitle'>
        {{t 'components.dummy_login_form.subtitle' htmlSafe=true}}
      </h2>

      <form class='form' {{on 'submit' (fn this.submit)}}>
        <input
          value={{this.email}}
          class='textInput'
          {{on 'keyup' (fn this.setEmail)}}
        />

        <button class='button button--filled button--green dummyLoginButton'>
          {{inlineSvg 'assets/check.svg' class=(scopedClass 'button-icon')}}
          {{t 'components.dummy_login_form.login_button'}}
        </button>
      </form>
    </div>
  </template>
  @service('session')
  declare session: Session;

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
