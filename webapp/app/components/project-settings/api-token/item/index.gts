import Component from '@glimmer/component';
import {service} from '@ember/service';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import {dropTask} from 'ember-concurrency';
import IntlService from 'ember-intl/services/intl';
import AccAvatarImg from 'accent-webapp/components/acc-avatar-img/index';
import t from 'ember-intl/helpers/t';
import TimeAgoInWordsTag from 'accent-webapp/components/time-ago-in-words-tag/index';
import {get, fn} from '@ember/helper';
import AsyncButton from 'accent-webapp/components/async-button/index';
import perform from 'ember-concurrency/helpers/perform';
import KeySvg from 'accent-webapp/svgs/assets/key.svg';
import XSvg from 'accent-webapp/svgs/assets/x.svg';
import {scopedClass} from 'ember-scoped-css';
import {on} from '@ember/modifier';

interface Args {
  token: any;
  permissions: Record<string, true>;
  onRevoke: (args: {id: string}) => Promise<void>;
}

export default class APITokenItem extends Component<Args> {
  <template>
    <div class='api-token'>
      <div class='api-token-header'>
        <div class='api-token-meta'>
          <div class='api-token-user'>
            {{#if @token.user.pictureUrl}}
              <AccAvatarImg src={{@token.user.pictureUrl}} class='picture' />
            {{else}}
              <AccAvatarImg
                src={{@token.user.pictureUrl}}
                @showFallback={{true}}
                class='picture'
              />
            {{/if}}

            <span class='api-token-name'>{{@token.user.fullname}}</span>
          </div>
          <span class='api-token-inserted'>
            {{t 'components.project_settings.api_token.inserted_at'}}
            <TimeAgoInWordsTag @date={{@token.insertedAt}} />
          </span>
          <span class='api-token-last-used'>
            {{#if @token.lastUsedAt}}
              {{t 'components.project_settings.api_token.last_used_at'}}
              <TimeAgoInWordsTag @date={{@token.lastUsedAt}} />
            {{else}}
              {{t 'components.project_settings.api_token.never_used'}}
            {{/if}}
          </span>
        </div>

        <div>
          {{#if (get @permissions 'revokeProjectApiToken')}}
            <AsyncButton
              @onClick={{perform this.revokeTask}}
              @loading={{this.isRevoking}}
              @disabled={{this.isRevoking}}
              class='button button--small button--filled button--red revoke-button'
            >
              <XSvg class='button-icon' />
              {{t 'components.project_settings.api_token.revoke_button'}}
            </AsyncButton>
          {{/if}}
        </div>
      </div>

      <div class='token-wrapper'>
        <KeySvg class={{scopedClass 'token-icon'}} />
        <input
          readonly
          onClick='this.select();'
          value={{@token.token}}
          class='token'
        />
      </div>

      {{#if @token.customPermissions}}
        <button
          class='toggle-permissions
            {{if this.showPermissions "toggle-permissions--open"}}'
          {{on 'click' (fn this.togglePermissions)}}
        >
          {{t
            'components.project_settings.api_token.permissions.custom_permissions'
          }}
          <span class='toggle-permissions-icon'>{{t
              'components.project_settings.api_token.permissions.custom_permissions_arrow'
            }}</span>
        </button>

        {{#if this.showPermissions}}
          <ul class='api-token-permissions'>
            {{#each @token.customPermissions as |permission|}}
              <li class='api-token-permission'>{{permission}}</li>
            {{/each}}
          </ul>
        {{/if}}
      {{/if}}
    </div>

    <style scoped>
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

      .api-token-last-used {
        opacity: 0.3;
        font-size: 10px;
      }

      .api-token-permissions {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
      }

      .api-token-permission {
        font-size: 11px;
        font-family: var(--font-monospace);
      }

      .revoke-button {
        opacity: 0;
        transition: 0.2s ease-in-out;
        transition-property: opacity;
        padding: 2px 4px !important;
      }

      .token {
        display: inline-block;
        width: 100%;
        margin: 10px 0 0;
        padding: 14px 8px 14px 30px;
        overflow-x: scroll;
        word-break: keep-all;
        border: 1px solid var(--input-border-color);
        background: var(--background-light);
        font-family: var(--font-monospace);
        font-size: 11px;
        border-radius: var(--border-radius);
        transition-property: border-color, box-shadow;
        transition: 0.3s ease-in-out;
        color: var(--text-color-normal);
        cursor: pointer;
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
        opacity: 0.4;
        pointer-events: none;
      }

      .toggle-permissions {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        background: transparent;
        padding: 3px 0;
        font-size: 12px;
        font-weight: bold;
        opacity: 0.7;
      }

      .toggle-permissions-icon {
        display: block;
        font-size: 10px;
        transition: 0.2s ease-in-out;
        transition-property: transform;
      }

      .toggle-permissions--open {
        opacity: 1;
      }

      .toggle-permissions--open .toggle-permissions-icon {
        transform: rotate(180deg);
      }
    </style>
  </template>
  @service('intl')
  declare intl: IntlService;

  @tracked
  showPermissions = false;

  get isRevoking() {
    return this.revokeTask.isRunning;
  }

  revokeTask = dropTask(async () => {
    const message = this.intl.t(
      'components.project_settings.api_token.revoke_confirm'
    );

    // eslint-disable-next-line no-alert
    if (!window.confirm(message)) {
      return;
    }

    await this.args.onRevoke(this.args.token);
  });

  @action
  togglePermissions() {
    this.showPermissions = !this.showPermissions;
  }
}
