// Vendor
import Component from '@glimmer/component';
import {action} from '@ember/object';
import config from 'accent-webapp/config/environment';
import {tracked} from '@glimmer/tracking';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';
import LoadingContent from 'accent-webapp/components/loading-content/index';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import {htmlSafe} from '@ember/template';

const ENTER_KEY = 13;

interface Args {
  providers: any;
}

export default class LoginForms extends Component<Args> {
  <template>
    <div class='container'>
      <div class='container-left'>
        <header class='login-header'>
          <h1 class='title'>
            {{inlineSvg 'assets/logo.svg' class=(scopedClass 'logo')}}
            {{t 'general.application_name'}}
          </h1>

          <p class='subtitle'>
            {{htmlSafe (t 'components.login_header.subtitle')}}
          </p>

          <p class='footer'>
            <a href='https://github.com/mirego/accent'>{{t
                'components.login_header.footer_open_source_link'
              }}</a>
            {{t 'components.login_header.footer'}}
            <a href='https://www.mirego.com'>{{t
                'components.login_header.footer_mirego_link'
              }}</a>
            <span class='version'>{{this.version}}</span>
          </p>
        </header>
      </div>

      <div class='container-right'>
        <div class='login-forms'>

          <h2 class='text'>
            <strong>
              {{t 'components.login_header.text'}}
            </strong>

            <p>
              {{t 'components.login_header.subtext'}}
            </p>
          </h2>

          {{#if @showLoading}}
            <LoadingContent class='loading' />
          {{/if}}

          {{#if @providers}}
            {{#if this.dummyLoginEnabled}}
              <input
                value={{this.username}}
                class='input'
                {{didInsert this.focusInput}}
                {{on 'keyup' (fn this.setUsername)}}
              />
              <a
                href={{this.dummyUrl}}
                class='button button--filled loginButton loginButton--dummy'
                disabled={{this.emptyUsername}}
              >
                {{t 'components.login_forms.dummy'}}
              </a>
            {{/if}}

            {{#if this.googleLoginEnabled}}
              <a
                href={{this.googleUrl}}
                class='button button--filled loginButton loginButton--google'
              >
                <img
                  src='assets/auth_providers/google.svg'
                  class='loginButton-logo'
                />
                {{t 'components.login_forms.google'}}
              </a>
            {{/if}}

            {{#if this.githubLoginEnabled}}
              <a
                href={{this.githubUrl}}
                class='button button--filled loginButton loginButton--github'
              >
                <img
                  src='assets/auth_providers/github.svg'
                  class='loginButton-logo'
                />
                {{t 'components.login_forms.github'}}
              </a>
            {{/if}}

            {{#if this.gitlabLoginEnabled}}
              <a
                href={{this.gitlabUrl}}
                class='button button--filled loginButton loginButton--gitlab'
              >
                <img
                  src='assets/auth_providers/gitlab.svg'
                  class='loginButton-logo'
                />
                {{t 'components.login_forms.gitlab'}}
              </a>
            {{/if}}

            {{#if this.slackLoginEnabled}}
              <a
                href={{this.slackUrl}}
                class='button button--filled loginButton loginButton--slack'
              >
                <img
                  src='assets/auth_providers/slack.svg'
                  class='loginButton-logo'
                />
                {{t 'components.login_forms.slack'}}
              </a>
            {{/if}}

            {{#if this.discordLoginEnabled}}
              <a
                href={{this.discordUrl}}
                class='button button--filled loginButton loginButton--discord'
              >
                <img
                  src='assets/auth_providers/discord.svg'
                  class='loginButton-logo'
                />
                {{t 'components.login_forms.discord'}}
              </a>
            {{/if}}

            {{#if this.microsoftLoginEnabled}}
              <a
                href={{this.microsoftUrl}}
                class='button button--filled loginButton loginButton--microsoft'
              >
                <img
                  src='assets/auth_providers/microsoft.svg'
                  class='loginButton-logo'
                />
                {{t 'components.login_forms.microsoft'}}
              </a>
            {{/if}}

            {{#if this.authZeroLoginEnabled}}
              <a
                href={{this.auth0Url}}
                class='button button--filled loginButton loginButton--auth0'
              >
                <img
                  src='assets/auth_providers/auth0.svg'
                  class='loginButton-logo'
                />
                {{t 'components.login_forms.auth0'}}
              </a>
            {{/if}}

            {{#if this.oidcLoginEnabled}}
              <a
                href={{this.oidcUrl}}
                class='button button--filled loginButton loginButton--oidc'
              >
                <img
                  src='assets/auth_providers/oidc.svg'
                  class='loginButton-logo'
                />
                {{t 'components.login_forms.oidc'}}
              </a>
            {{/if}}
          {{/if}}
        </div>
      </div>
    </div>
  </template>
  @tracked
  username = '';

  googleUrl = `${config.API.AUTHENTICATION_PATH}/google`;
  githubUrl = `${config.API.AUTHENTICATION_PATH}/github`;
  gitlabUrl = `${config.API.AUTHENTICATION_PATH}/gitlab`;
  slackUrl = `${config.API.AUTHENTICATION_PATH}/slack`;
  discordUrl = `${config.API.AUTHENTICATION_PATH}/discord`;
  microsoftUrl = `${config.API.AUTHENTICATION_PATH}/microsoft`;
  auth0Url = `${config.API.AUTHENTICATION_PATH}/auth0`;
  oidcUrl = `${config.API.AUTHENTICATION_PATH}/oidc`;

  get version() {
    return config.version === '__VERSION__' ? 'dev' : config.version;
  }

  get providerIds() {
    return this.args.providers.map(({id}: {id: string}) => id);
  }

  get authZeroLoginEnabled() {
    return this.providerIds.includes('auth0');
  }

  get googleLoginEnabled() {
    return this.providerIds.includes('google');
  }

  get dummyLoginEnabled() {
    return this.providerIds.includes('dummy');
  }

  get githubLoginEnabled() {
    return this.providerIds.includes('github');
  }

  get gitlabLoginEnabled() {
    return this.providerIds.includes('gitlab');
  }

  get slackLoginEnabled() {
    return this.providerIds.includes('slack');
  }

  get discordLoginEnabled() {
    return this.providerIds.includes('discord');
  }

  get microsoftLoginEnabled() {
    return this.providerIds.includes('microsoft');
  }

  get oidcLoginEnabled() {
    return this.providerIds.includes('oidc');
  }

  get dummyUrl() {
    return `${config.API.AUTHENTICATION_PATH}/dummy/callback?email=${this.username}`;
  }

  get emptyUsername() {
    return this.username === '';
  }

  @action
  setUsername(event: any) {
    this.username = event.currentTarget.value;
    if (event.keyCode === ENTER_KEY && !this.emptyUsername)
      window.location.href = this.dummyUrl;
  }

  @action
  focusInput(element: HTMLElement) {
    element.focus();
  }
}
