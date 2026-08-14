// Vendor
import Component from '@glimmer/component';
import {action} from '@ember/object';
import config from 'accent-webapp/config/environment';
import {tracked} from '@glimmer/tracking';
import LogoSvg from 'accent-webapp/svgs/assets/logo.svg';
import GoogleSvg from 'accent-webapp/svgs/assets/auth_providers/google.svg';
import GithubSvg from 'accent-webapp/svgs/assets/auth_providers/github.svg';
import GitlabSvg from 'accent-webapp/svgs/assets/auth_providers/gitlab.svg';
import SlackSvg from 'accent-webapp/svgs/assets/auth_providers/slack.svg';
import DiscordSvg from 'accent-webapp/svgs/assets/auth_providers/discord.svg';
import MicrosoftSvg from 'accent-webapp/svgs/assets/auth_providers/microsoft.svg';
import Auth0Svg from 'accent-webapp/svgs/assets/auth_providers/auth0.svg';
import OidcSvg from 'accent-webapp/svgs/assets/auth_providers/oidc.svg';
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
            <LogoSvg class={{scopedClass 'logo'}} />
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
                <GoogleSvg class={{scopedClass 'loginButton-logo'}} />
                {{t 'components.login_forms.google'}}
              </a>
            {{/if}}

            {{#if this.githubLoginEnabled}}
              <a
                href={{this.githubUrl}}
                class='button button--filled loginButton loginButton--github'
              >
                <GithubSvg class={{scopedClass 'loginButton-logo'}} />
                {{t 'components.login_forms.github'}}
              </a>
            {{/if}}

            {{#if this.gitlabLoginEnabled}}
              <a
                href={{this.gitlabUrl}}
                class='button button--filled loginButton loginButton--gitlab'
              >
                <GitlabSvg class={{scopedClass 'loginButton-logo'}} />
                {{t 'components.login_forms.gitlab'}}
              </a>
            {{/if}}

            {{#if this.slackLoginEnabled}}
              <a
                href={{this.slackUrl}}
                class='button button--filled loginButton loginButton--slack'
              >
                <SlackSvg class={{scopedClass 'loginButton-logo'}} />
                {{t 'components.login_forms.slack'}}
              </a>
            {{/if}}

            {{#if this.discordLoginEnabled}}
              <a
                href={{this.discordUrl}}
                class='button button--filled loginButton loginButton--discord'
              >
                <DiscordSvg class={{scopedClass 'loginButton-logo'}} />
                {{t 'components.login_forms.discord'}}
              </a>
            {{/if}}

            {{#if this.microsoftLoginEnabled}}
              <a
                href={{this.microsoftUrl}}
                class='button button--filled loginButton loginButton--microsoft'
              >
                <MicrosoftSvg class={{scopedClass 'loginButton-logo'}} />
                {{t 'components.login_forms.microsoft'}}
              </a>
            {{/if}}

            {{#if this.authZeroLoginEnabled}}
              <a
                href={{this.auth0Url}}
                class='button button--filled loginButton loginButton--auth0'
              >
                <Auth0Svg class={{scopedClass 'loginButton-logo'}} />
                {{t 'components.login_forms.auth0'}}
              </a>
            {{/if}}

            {{#if this.oidcLoginEnabled}}
              <a
                href={{this.oidcUrl}}
                class='button button--filled loginButton loginButton--oidc'
              >
                <OidcSvg class={{scopedClass 'loginButton-logo'}} />
                {{t 'components.login_forms.oidc'}}
              </a>
            {{/if}}
          {{/if}}
        </div>
      </div>
    </div>

    <style scoped>
      .input {
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
      .input::-moz-selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .input::selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .input:focus {
        border: 2px solid var(--color-primary);
      }
      .input:disabled {
        color: var(--color-grey);
        background: var(--background-light);
      }

      @media (hover: none) and (max-width: 640px) {
        .input {
          font-size: 16px !important;
        }
      }
      .login-forms {
        display: flex;
        flex-direction: column;
        align-items: center;
        max-width: 500px;
        margin: 0 0 0 50px;
        padding: 30px 30px 20px 30px;
        border-radius: 6px;
        background: var(--content-background);
        box-shadow:
          0 1px 4px var(--shadow-color),
          0 7px 12px var(--shadow-color);
      }
      .login-forms .text {
        max-width: 300px;
        margin-bottom: 20px;
        font-size: 12px;
        text-align: center;
        color: var(--text-color-normal);
      }
      .login-forms .text strong {
        display: block;
        font-size: 25px;
        font-weight: 900;
        margin-bottom: 10px;
      }
      .login-forms .text p {
        opacity: 0.6;
      }

      .loading {
        padding: 0;
        margin: 0;
      }
      .loading :global(svg) {
        width: 20px;
      }

      .version {
        font-family: var(--font-monospace);
        margin-left: 10px;
        opacity: 0.4;
      }

      .login-header {
        max-width: 570px;
        margin: -60px 50px 0 auto;
        padding: 0 10px;
      }
      .login-header .title {
        font-weight: 900;
        display: flex;
        gap: 10px;
        align-items: center;
        font-size: 20px;
        margin-bottom: 20px;
        letter-spacing: 0;
      }
      .login-header .subtitle {
        line-height: 1.1;
        font-size: 55px;
        font-weight: 900;
        letter-spacing: -1px;
      }
      .login-header .subtitle em {
        font-style: normal;
        position: relative;
      }
      .login-header .footer {
        opacity: 0.5;
        font-size: 12px;
        margin-top: 20px;
      }
      .login-header .footer a {
        color: inherit;
        text-decoration: none;
      }
      .login-header .logo {
        width: 25px;
      }

      .input {
        max-width: 300px;
        padding: 10px;
        width: 100%;
        font-size: 13px;
      }
      .input:focus {
        border-color: var(--color-green);
      }

      .container {
        display: flex;
        width: 100%;
        height: 100vh;
      }

      .container-left {
        background: linear-gradient(
          0deg,
          var(--background-light-highlight) 0%,
          var(--background-light) 100%
        );
      }

      .container-right {
        background: var(--background-light);
      }

      .container-right,
      .container-left {
        display: flex;
        justify-content: flex-start;
        align-items: center;
        width: 50%;
        padding: 30px;
      }

      a.loginButton {
        max-width: 300px;
        position: relative;
        display: inline-flex;
        justify-content: center;
        width: 100%;
        padding: 12px 10px;
        margin-bottom: 15px;
        text-align: center;
        background: var(--input-background);
        border-radius: 5px;
        border: 1px solid #888;
        font-size: 13px;
      }
      a.loginButton:focus {
        box-shadow: 0 3px 10px var(--shadow-color);
      }
      a.loginButton.loginButton--google {
        border-color: rgb(51.6424581006, 128.187150838, 253.8575418994);
        text-shadow: none;
        color: #4d90fe;
        background: rgb(229.1452513966, 238.8770949721, 254.8547486034);
      }
      a.loginButton.loginButton--dummy {
        border: 1px solid var(--content-background-border);
        color: var(--input-color);
        text-shadow: none;
        border-radius: var(--border-radius);
        margin-top: 5px;
        margin-bottom: 25px;
        padding-top: 7px;
        padding-bottom: 7px;
      }
      a.loginButton.loginButton--dummy[disabled] {
        pointer-events: none;
      }
      a.loginButton.loginButton--dummy .loginButton-logo {
        left: 15px;
        top: 8px;
        width: 16px;
        opacity: 0.9;
      }
      a.loginButton.loginButton--dummy:hover[disabled],
      a.loginButton.loginButton--dummy:focus,
      a.loginButton.loginButton--dummy:hover {
        background: var(--background-light);
        color: var(--text-color-normal);
      }
      a.loginButton.loginButton--github {
        text-shadow: none;
        color: #000;
        background: #fff;
        background: #eee;
      }
      a.loginButton.loginButton--auth0 {
        border-color: #eb5424;
        text-shadow: none;
        color: #eb5424;
        background: rgb(253.3514644351, 240.9050209205, 236.9485355649);
      }
      a.loginButton.loginButton--gitlab {
        border-color: #fc6d26;
        text-shadow: none;
        color: #fc6d26;
        background: rgb(254.7818181818, 244.3818181818, 239.2181818182);
      }
      a.loginButton.loginButton--slack {
        border-color: #913d91;
        text-shadow: none;
        color: #913d91;
        background: rgb(245.0208737864, 231.2791262136, 245.0208737864);
      }
      a.loginButton.loginButton--discord {
        border-color: #7289da;
        text-shadow: none;
        color: #7289da;
        background: rgb(235.1966292135, 238.4269662921, 249.8033707865);
      }
      a.loginButton.loginButton--microsoft {
        border-color: #03a5f0;
        text-shadow: none;
        color: #03a5f0;
        background: rgb(233.0740740741, 247.8740740741, 254.7259259259);
      }
      a.loginButton.loginButton--oidc {
        border-color: #f7931e;
        text-shadow: none;
        color: #f7931e;
        background: white;
      }

      .loginButton-logo {
        position: absolute;
        left: 14px;
        top: 12px;
        width: 20px;
        margin-right: 10px;
        color: #fff;
        font-size: 26px;
        line-height: 1;
      }

      @media (max-width: 900px) {
        .container {
          flex-direction: column;
        }
        .container-left,
        .container-right {
          justify-content: center;
          width: 100%;
          padding: 20px;
          background: transparent;
        }
        .login-header {
          margin: 0;
          padding: 0;
        }
        .login-header .subtitle {
          font-size: 30px;
        }
        .login-forms {
          margin: 0;
        }
      }
    </style>
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
