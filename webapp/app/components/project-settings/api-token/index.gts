import Component from '@glimmer/component';
import {service} from '@ember/service';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import {dropTask} from 'ember-concurrency';
import IntlService from 'ember-intl/services/intl';
import {CreateApiTokenResponse} from 'accent-webapp/queries/create-api-token';
import {get, fn, concat} from '@ember/helper';
import t from 'ember-intl/helpers/t';
import {htmlSafe} from '@ember/template';
import Item from 'accent-webapp/components/project-settings/api-token/item/index';
import onKey from 'ember-keyboard/modifiers/on-key';
import perform from 'ember-concurrency/helpers/perform';
import {on} from '@ember/modifier';
import AsyncButton from 'accent-webapp/components/async-button/index';
import CodeSvg from 'accent-webapp/svgs/assets/code.svg';
import KeySvg from 'accent-webapp/svgs/assets/key.svg';
import UsersSvg from 'accent-webapp/svgs/assets/users.svg';
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
          <div class='panel'>
            <div class='panel-head'>
              <div>
                <h2 class='panel-title'>
                  {{t 'components.project_settings.api_token.title'}}
                </h2>
                <p class='panel-text'>
                  {{htmlSafe
                    (t 'components.project_settings.api_token.text_1')
                  }}
                </p>
              </div>
            </div>

            {{#if @projectTokens.length}}
              <div class='api-tokens {{if this.isRevoking "overlay"}}'>
                {{#each @projectTokens key='id' as |token|}}
                  <Item
                    @token={{token}}
                    @permissions={{@permissions}}
                    @onRevoke={{@onRevoke}}
                  />
                {{/each}}
              </div>
            {{else}}
              <div class='empty'>
                <KeySvg class={{scopedClass 'empty-icon'}} />
                {{t 'components.project_settings.api_token.empty'}}
              </div>
            {{/if}}
          </div>

          {{#if (get @permissions 'createProjectApiToken')}}
            <div class='form'>
              <h2 class='form-title'>
                {{t 'components.project_settings.api_token.create_title'}}
              </h2>

              <div class='form-fields'>
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
              </div>

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
                  <div class='toggle-permissions-header-actions'>
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
                      <label
                        class='permissions-input-label'
                        for={{concat 'permission-' permission}}
                      >
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
        <div class='panel-head'>
          <div>
            <h2 class='panel-title'>
              {{t 'components.project_settings.user_token.title'}}
            </h2>
            <p class='panel-text'>
              {{t 'components.project_settings.user_token.text_1'}}
            </p>
          </div>
        </div>

        <p class='text'>
          {{htmlSafe (t 'components.project_settings.user_token.text_shell')}}
        </p>

        <div class='token-wrapper'>
          <KeySvg class={{scopedClass 'token-icon'}} />
          <input
            readonly
            onClick='this.select();'
            value={{@userToken}}
            class='token'
          />
        </div>
      </div>
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
      .project-settings-api-token {
        display: flex;
        gap: 24px;
        align-items: flex-start;
        margin-top: 30px;
      }

      .text {
        margin: 14px 0 0;
        font-size: 13px;
        line-height: 1.5;
        color: color-mix(in srgb, var(--text-color-normal) 65%, transparent);
      }

      .text code,
      .panel-text code {
        padding: 1px 5px;
        border-radius: var(--border-radius);
        background: color-mix(in srgb, var(--color-primary) 10%, transparent);
        font-family: var(--font-monospace);
        font-size: 12px;
        color: var(--color-primary);
      }

      .tokens {
        display: flex;
        flex: 1 1 60%;
        flex-direction: column;
        gap: 20px;
      }

      .panel,
      .user-token {
        border-radius: var(--border-radius);
        background-color: var(--content-background);
      }

      .user-token {
        padding: 20px;
        flex: 1 1 40%;
        background-color: var(--background-light);
      }

      .panel-head {
        display: flex;
        gap: 14px;
        align-items: flex-start;
        margin-bottom: 18px;
      }

      .panel-icon {
        display: inline-flex;
        flex-shrink: 0;
        align-items: center;
        justify-content: center;
        box-sizing: content-box;
        width: 18px;
        height: 18px;
        padding: 9px;
        border-radius: var(--border-radius);
        color: var(--color-primary);
        background: color-mix(in srgb, var(--color-primary) 12%, transparent);
      }
      .panel-iconSvg {
        width: 18px;
        height: 18px;
        stroke: var(--color-primary);
      }

      .panel-title {
        margin: 0;
        font-size: 16px;
        font-weight: 700;
        color: var(--text-color-normal);
      }

      .panel-text {
        margin: 4px 0 0;
        font-size: 13px;
        line-height: 1.5;
        color: color-mix(in srgb, var(--text-color-normal) 65%, transparent);
      }

      .empty {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 10px;
        padding: 32px 20px;
        border-radius: var(--border-radius);
        border: 1px dashed var(--background-light-highlight);
        background: var(--background-light);
        text-align: center;
        font-size: 13px;
        color: color-mix(in srgb, var(--text-color-normal) 55%, transparent);
      }
      .empty-icon {
        width: 26px;
        height: 26px;
        opacity: 0.4;
      }

      .api-tokens {
        display: flex;
        flex-direction: column;
        gap: 16px;
      }
      .api-tokens :global(.api-token) {
        border-radius: var(--border-radius);
        background: var(--background-light);
      }

      .api-tokens.overlay {
        position: relative;
        pointer-events: none;
      }
      .api-tokens.overlay::after {
        content: '';
        background: rgba(255, 255, 255, 0.5);
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
      }

      .api-token {
        display: flex;
        flex-direction: column;
        gap: 0;
      }

      .api-token:hover .revoke-button {
        opacity: 1;
      }

      .api-token-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
      }

      .api-token-meta {
        display: flex;
        align-items: center;
        gap: 7px;
      }

      .api-token-user {
        display: flex;
        align-items: center;
        gap: 4px;
      }

      .api-token-name {
        font-weight: bold;
        font-size: 12px;
      }

      .api-token-inserted {
        opacity: 0.3;
        font-size: 10px;
      }

      .api-token-permissions {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
      }

      .api-token-permissions-label {
        font-size: 12px;
        font-weight: bold;
        opacity: 0.7;
      }

      .api-token-permission {
        padding: 1px 3px;
        border-radius: var(--border-radius);
        background-color: var(--background-light);
        border: 1px solid var(--background-light-highlight);
        font-size: 11px;
        font-family: var(--font-monospace);
      }

      .revoke-button {
        opacity: 0;
        transition: 0.2s ease-in-out;
        transition-property: opacity;
        padding: 2px 4px !important;
      }

      .create-button {
        margin-top: 4px;
      }

      .permissions-inputs {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
        gap: 8px;
        width: 100%;
        padding: 0;
        margin: 0;
        list-style: none;
      }

      .permissions-input {
        font-size: 12px;
        font-family: var(--font-monospace);
      }

      .permissions-input-label {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 7px 10px;
        border-radius: var(--border-radius);
        border: 1px solid var(--background-light-highlight);
        background: var(--content-background);
        cursor: pointer;
        transition: 0.2s ease-in-out;
        transition-property: border-color, background;
      }
      .permissions-input-label:hover {
        border-color: color-mix(in srgb, var(--color-primary) 40%, transparent);
      }
      .permissions-input-label:has(input:checked) {
        border-color: var(--color-primary);
        background: color-mix(in srgb, var(--color-primary) 8%, transparent);
      }
      .permissions-input-label input {
        accent-color: var(--color-primary);
      }

      .toggle-permissions-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        width: 100%;
      }

      .toggle-permissions-header-actions {
        display: flex;
        gap: 12px;
      }

      .toggle-permissions-header-button {
        background: transparent;
        border: none;
        color: var(--color-primary);
        font-size: 12px;
        font-weight: 600;
        cursor: pointer;
      }
      .toggle-permissions-header-button:hover {
        text-decoration: underline;
      }

      .toggle-permissions-input {
        display: flex;
        align-items: center;
        gap: 5px;
        background: transparent;
        border: none;
        padding: 3px 0;
        font-size: 12px;
        font-weight: bold;
        opacity: 0.7;
        color: var(--text-color-normal);
        cursor: pointer;
      }
      .toggle-permissions-input:hover {
        opacity: 1;
      }

      .toggle-permissions-input-icon {
        display: block;
        font-size: 10px;
        transition: 0.2s ease-in-out;
        transition-property: transform;
      }

      .toggle-permissions-input--open {
        opacity: 1;
      }

      .toggle-permissions-input--open .toggle-permissions-input-icon {
        transform: rotate(180deg);
      }

      .picture {
        width: 14px;
        height: 14px;
        object-fit: cover;
        border-radius: var(--border-radius);
      }

      .form {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        gap: 14px;
        padding: 20px;
        background: var(--content-background);
        border-radius: var(--border-radius);
        box-shadow: 0 2px 8px var(--shadow-color);
      }

      .form-title {
        margin: 0;
        font-size: 14px;
        font-weight: 700;
        color: var(--text-color-normal);
      }

      .form-fields {
        display: flex;
        flex-direction: column;
        gap: 8px;
        width: 100%;
      }

      .textInput {
        padding: 8px 10px;
        width: 100%;
        font-family: var(--font-primary);
        font-size: 13px;
      }

      .token {
        display: inline-block;
        width: 100%;
        margin: 14px 0 0;
        padding: 13px 10px 13px 34px;
        overflow-x: auto;
        word-break: keep-all;
        border: 1px solid var(--background-light-highlight);
        background: var(--content-background);
        font-family: var(--font-monospace);
        font-size: 11px;
        border-radius: var(--border-radius);
        transition-property: border-color, box-shadow;
        transition: 0.3s ease-in-out;
        color: var(--text-color-normal);
        cursor: pointer;
      }
      .token:hover {
        border-color: color-mix(in srgb, var(--color-primary) 40%, transparent);
      }
      .token:focus {
        outline: none;
        border-color: color-mix(in srgb, var(--color-primary) 70%, transparent);
        box-shadow: 0 0 3px 2px
          color-mix(in srgb, var(--color-primary) 10%, transparent);
      }
      .token:focus::-moz-selection {
        background: color-mix(in srgb, var(--color-primary) 10%, transparent);
      }
      .token:focus::selection {
        background: color-mix(in srgb, var(--color-primary) 10%, transparent);
      }

      .token-wrapper {
        position: relative;
      }

      .token-icon {
        position: absolute;
        left: 12px;
        top: 25px;
        width: 14px;
        height: 14px;
        opacity: 0.5;
        pointer-events: none;
      }

      @media (max-width: 840px) {
        .project-settings-api-token {
          flex-direction: column;
        }

        .tokens,
        .user-token {
          width: 100%;
        }
      }
    </style>
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
