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

  get providerIds() {
    return this.args.providers.map(({id}: {id: string}) => id);
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

  get dummyUrl() {
    return `${config.API.AUTHENTICATION_PATH}/dummy/callback?email=${this.username}`;
  }

  @action
  setUsername(event: any) {
    if (event.keyCode === ENTER_KEY) window.location.href = this.dummyUrl;
    this.username = event.currentTarget.value;
  }
}
