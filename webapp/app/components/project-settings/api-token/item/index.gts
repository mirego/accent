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
import inlineSvg from 'accent-webapp/helpers/inline-svg';
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
              {{inlineSvg '/assets/x.svg' class='button-icon'}}
              {{t 'components.project_settings.api_token.revoke_button'}}
            </AsyncButton>
          {{/if}}
        </div>
      </div>

      <div class='token-wrapper'>
        {{inlineSvg '/assets/key.svg' class=(scopedClass 'token-icon')}}
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
