import {service} from '@ember/service';
import {action} from '@ember/object';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';
import {dropTask} from 'ember-concurrency';
import AccSelect from 'accent-webapp/components/acc-select/index';
import {fn} from '@ember/helper';
import t from 'ember-intl/helpers/t';
import onKey from 'ember-keyboard/modifiers/on-key';
import perform from 'ember-concurrency/helpers/perform';
import {on} from '@ember/modifier';
import AsyncButton from 'accent-webapp/components/async-button/index';

interface Args {
  project: any;
  onCreate: ({email, role}: {email: string; role: string}) => Promise<void>;
}

const invalidEmail = (email: string) => !email.match(/@/);

export default class CreateForm extends Component<Args> {
  <template>
    <div class='project-settings-collaborators-create-form'>
      <AccSelect
        @searchEnabled={{false}}
        @selected={{this.roleValue}}
        @options={{this.mappedPossibleRoles}}
        @onchange={{fn this.setRole}}
        class='select'
      />

      <input
        type='email'
        value={{this.email}}
        placeholder={{t
          'components.collaborator_create_form.email_placeholder'
        }}
        data-test-new-collaborator-email
        class='textInput'
        {{onKey 'cmd+Enter' (perform this.submitTask)}}
        {{on 'input' (fn this.emailChanged)}}
      />

      <AsyncButton
        @onClick={{perform this.submitTask}}
        @loading={{this.isCreating}}
        @disabled={{this.invalidEmail}}
        class='button button--filled'
        data-test-new-collaborator-submit
      >
        {{t 'components.collaborator_create_form.create_button'}}
      </AsyncButton>
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
      .project-settings-collaborators-create-form {
        display: flex;
        align-items: center;
      }
      .project-settings-collaborators-create-form select {
        margin-right: 10px;
        padding: 9px 25px 8px 5px;
      }
      .project-settings-collaborators-create-form :global(.button) {
        margin-right: 5px;
      }
      .project-settings-collaborators-create-form
        :global(.button)
        :global(.label) {
        padding-top: 9px;
        padding-bottom: 9px;
      }

      .select {
        margin-right: 10px;
        flex-shrink: 0;
      }

      .textInput {
        flex-grow: 1;
        flex-shrink: 1;
        padding: 8px 10px;
        margin-right: 10px;
        max-width: 350px;
        width: 100%;
        font-family: var(--font-primary);
        font-size: 12px;
      }
    </style>
  </template>
  @service('intl')
  declare intl: IntlService;

  @service('global-state')
  declare globalState: GlobalState;

  @tracked
  isCreating = false;

  @tracked
  email = '';

  @tracked
  role = this.possibleRoles[0];

  @tracked
  invalidEmail = invalidEmail(this.email);

  get possibleRoles() {
    return this.globalState.roles.map(({slug}: {slug: string}) => slug);
  }

  get mappedPossibleRoles() {
    return this.possibleRoles.map((value) => ({
      label: this.intl.t(`general.roles.${value}`),
      value
    }));
  }

  get roleValue() {
    return this.mappedPossibleRoles.find(({value}) => value === this.role);
  }

  submitTask = dropTask(async () => {
    if (!this.email || !this.role) return;

    this.isCreating = true;

    await this.args.onCreate({email: this.email, role: this.role});

    this.email = '';
    this.isCreating = false;
  });

  @action
  setRole({value}: {value: string}) {
    this.role = value;
  }

  @action
  emailChanged(event: any) {
    this.email = event.target.value;
    this.invalidEmail = invalidEmail(event.target.value);
  }
}
