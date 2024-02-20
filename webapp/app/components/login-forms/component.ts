// Vendor
import Component from '@glimmer/component';
import {action} from '@ember/object';
import config from 'accent-webapp/config/environment';
import {tracked} from '@glimmer/tracking';

const ENTER_KEY = 13;

interface Args {
  providers: any;
}

export default class LoginForms extends Component<Args> {
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
