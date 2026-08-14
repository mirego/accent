import {service} from '@ember/service';
import Component from '@glimmer/component';
import {action} from '@ember/object';
import Session from 'accent-webapp/services/session';
import {tracked} from '@glimmer/tracking';
import t from 'ember-intl/helpers/t';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import CheckSvg from 'accent-webapp/svgs/assets/check.svg';
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
          <CheckSvg class={{scopedClass 'button-icon'}} />
          {{t 'components.dummy_login_form.login_button'}}
        </button>
      </form>
    </div>

    <style scoped>
      .textInput {
        transition: 0.2s ease-in-out;
        transition-property: background, border, box-shadow;
        resize: vertical;
        outline: 0;
        border-radius: var(--border-radius);
        border: 2px solid var(--input-border-color);
        background: var(--input-background);
        color: var(--input-color);
        font-family: var(--font-monospace);
        line-height: 1.4;
        max-height: 200px;
      }
      .textInput::-moz-selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .textInput::selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .textInput:focus {
        border: 2px solid var(--color-primary);
      }
      .textInput:disabled {
        color: var(--color-grey);
        background: var(--background-light);
      }

      @media (hover: none) and (max-width: 640px) {
        .textInput {
          font-size: 16px !important;
        }
      }
      .dummy-login-form {
        max-width: 500px;
        margin: 100px auto 30px;
        padding: 20px;
        box-shadow: 0 3px 21px var(--shadow-color);
        border: 1px solid var(--background-light-highlight);
        background: var(--background-light);
        text-align: center;
      }

      .title {
        margin-bottom: 15px;
        font-weight: 700;
        font-size: 19px;
      }

      .warning {
        display: inline-block;
        padding: 10px 15px;
        margin-bottom: 20px;
        font-weight: bold;
        font-size: 12px;
        color: var(--color-error);
      }

      .subtitle {
        margin: 0 15px 25px;
        font-size: 13px;
        color: var(--color-grey);
      }

      .form {
        display: flex;
        align-items: stretch;
      }

      .textInput {
        flex: 1 1 auto;
        padding: 10px;
        margin: 0 0 0 0;
        border-radius: 3px 0 0 3px;
        border-right: 0;
        font-size: 13px;
      }
      .textInput:focus {
        border-right: 0;
        border-color: var(--color-green);
      }

      .dummyLoginButton {
        flex: 0 1 auto !important;
        border-radius: 0 3px 3px 0 !important;
      }

      @media (max-width: 440px) {
        .dummy-login-form {
          margin-top: 30px;
        }
      }
    </style>
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
