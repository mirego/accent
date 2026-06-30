import Component from '@glimmer/component';
import {service} from '@ember/service';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import {dropTask} from 'ember-concurrency';
import IntlService from 'ember-intl/services/intl';
import {CreateApiTokenResponse} from 'accent-webapp/queries/create-api-token';
import {get, fn, concat} from '@ember/helper';
import Title from 'accent-webapp/components/project-settings/title/index';
import t from 'ember-intl/helpers/t';
import {htmlSafe} from '@ember/template';
import Item from 'accent-webapp/components/project-settings/api-token/item/index';
import onKey from 'ember-keyboard/modifiers/on-key';
import perform from 'ember-concurrency/helpers/perform';
import {on} from '@ember/modifier';
import AsyncButton from 'accent-webapp/components/async-button/index';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {scopedClass} from 'ember-scoped-css';

interface Args {
  permissions: Record<string, true>;
  projectToken: string;
  userToken: string;
  onCreate: (args: {
    name: string;
    pictureUrl: string | null;
    permissions: string[];
  }) => Promise<any>;
  onRevoke: (args: {id: string}) => void;
}

const camelToSnake = (str: string): string =>
  str.replace(/([A-Z])/g, (letter) => `_${letter.toLowerCase()}`);

export default class APIToken extends Component<Args> {
  <template>
    <div class='project-settings-api-token'>
      {{#if (get @permissions 'listProjectApiTokens')}}
        <div class='tokens'>
          <Title
            @icon='/assets/code.svg'
            @title={{t 'components.project_settings.api_token.title'}}
          />

          <p class='text'>
            {{htmlSafe (t 'components.project_settings.api_token.text_1')}}
          </p>

          <div class='api-tokens {{if this.isRevoking "overlay"}}'>
            {{#each @projectTokens key='id' as |token|}}
              <Item
                @token={{token}}
                @permissions={{@permissions}}
                @onRevoke={{@onRevoke}}
              />
            {{/each}}
          </div>

          {{#if (get @permissions 'createProjectApiToken')}}
            <div class='form'>
              <Title
                @title={{t
                  'components.project_settings.api_token.create_title'
                }}
              />

              <input
                type='text'
                value={{this.apiTokenName}}
                placeholder={{t
                  'components.project_settings.api_token.create_name_placeholder'
                }}
                class='textInput'
                {{onKey 'cmd+Enter' (perform this.submitTask)}}
                {{on 'input' (fn this.apiTokenNameChanged)}}
              />

              <input
                type='url'
                value={{this.apiTokenPictureUrl}}
                placeholder={{t
                  'components.project_settings.api_token.create_picture_url_placeholder'
                }}
                class='textInput'
                {{onKey 'cmd+Enter' (perform this.submitTask)}}
                {{on 'input' (fn this.apiTokenPictureUrlChanged)}}
              />
              <div class='toggle-permissions-header'>

                <button
                  class='toggle-permissions-input
                    {{if
                      this.showPermissionsInput
                      "toggle-permissions-input--open"
                    }}'
                  {{on 'click' (fn this.togglePermissionsInput)}}
                >
                  {{t
                    'components.project_settings.api_token.permissions.use_custom_permissions'
                  }}
                  <span class='toggle-permissions-input-icon'>
                    {{t
                      'components.project_settings.api_token.permissions.custom_permissions_arrow'
                    }}
                  </span>
                </button>

                {{#if this.showPermissionsInput}}
                  <div>
                    <button
                      class='toggle-permissions-header-button'
                      {{on 'click' (fn this.selectAllPermissions)}}
                    >
                      {{t
                        'components.project_settings.api_token.permissions.select_all'
                      }}
                    </button>
                    <button
                      class='toggle-permissions-header-button'
                      {{on 'click' (fn this.unselectAllPermissions)}}
                    >
                      {{t
                        'components.project_settings.api_token.permissions.unselect_all'
                      }}
                    </button>
                  </div>
                {{/if}}
              </div>

              {{#if this.showPermissionsInput}}
                <ul class='permissions-inputs'>
                  {{#each-in this.snakeCasePermissions as |permission|}}
                    <li class='permissions-input'>
                      <label for={{concat 'permission-' permission}}>
                        <input
                          name='permiss'
                          value={{permission}}
                          type='checkbox'
                          id={{concat 'permission-' permission}}
                          {{on 'input' (fn this.changePermission)}}
                        />
                        {{permission}}
                      </label>
                    </li>
                  {{/each-in}}
                </ul>
              {{/if}}

              <AsyncButton
                class='button button--filled create-button'
                @disabled={{this.isSubmitDisabled}}
                @onClick={{perform this.submitTask}}
                @loading={{this.isSubmitting}}
              >
                {{t 'components.project_settings.api_token.create_button'}}
              </AsyncButton>
            </div>
          {{/if}}

        </div>
      {{/if}}

      <div class='user-token'>
        <Title
          @icon='/assets/users.svg'
          @title={{t 'components.project_settings.user_token.title'}}
        />

        <p class='text'>
          {{t 'components.project_settings.user_token.text_1'}}
        </p>

        <p class='text'>
          {{htmlSafe (t 'components.project_settings.user_token.text_shell')}}
        </p>

        <div class='token-wrapper'>
          {{inlineSvg '/assets/key.svg' class=(scopedClass 'token-icon')}}
          <input
            readonly
            onClick='this.select();'
            value={{@userToken}}
            class='token'
          />
        </div>
      </div>
    </div>
  </template>
  @service('intl')
  declare intl: IntlService;

  @tracked
  isEdit = false;

  get snakeCasePermissions(): Record<string, true> {
    return Object.fromEntries(
      Object.keys(this.args.permissions).map((key) => [
        camelToSnake(key),
        true as const
      ])
    );
  }

  @tracked
  showPermissionsInput = false;

  @tracked
  apiTokenName = '';

  @tracked
  apiTokenPermissions: string[] = [];

  @tracked
  apiTokenPictureUrl: string | null = null;

  @action
  onToggleForm() {
    this.isEdit = !this.isEdit;
  }

  get isSubmitting() {
    return this.submitTask.isRunning;
  }

  get isSubmitDisabled() {
    return !this.apiTokenName || this.apiTokenName.length === 0;
  }

  submitTask = dropTask(async () => {
    if (!this.apiTokenName) return;

    const response: CreateApiTokenResponse = await this.args.onCreate({
      name: this.apiTokenName,
      pictureUrl: this.apiTokenPictureUrl,
      permissions: this.apiTokenPermissions
    });

    if (response.apiToken) {
      this.apiTokenName = '';
      this.apiTokenPictureUrl = '';
      this.showPermissionsInput = false;
      this.unselectAllPermissions();
    }
  });

  @action
  changePermission() {
    this.apiTokenPermissions = Array.from(
      document.querySelectorAll<HTMLInputElement>(
        'input[name="permiss"]:checked'
      )
    ).map((input) => input.value);
  }

  @action
  togglePermissionsInput() {
    this.showPermissionsInput = !this.showPermissionsInput;
  }

  @action
  selectAllPermissions() {
    Array.from(
      document.querySelectorAll<HTMLInputElement>('input[name="permiss"]')
    ).forEach((input) => (input.checked = true));

    this.apiTokenPermissions = Array.from(
      document.querySelectorAll<HTMLInputElement>(
        'input[name="permiss"]:checked'
      )
    ).map((input) => input.value);
  }

  @action
  unselectAllPermissions() {
    Array.from(
      document.querySelectorAll<HTMLInputElement>('input[name="permiss"]')
    ).forEach((input) => (input.checked = false));
    this.apiTokenPermissions = [];
  }

  @action
  apiTokenNameChanged(event: any) {
    this.apiTokenName = event.target.value;
  }

  @action
  apiTokenPictureUrlChanged(event: any) {
    this.apiTokenPictureUrl = event.target.value;
  }
}
