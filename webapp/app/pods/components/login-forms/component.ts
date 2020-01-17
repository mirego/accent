// Vendor
import Component from '@ember/component';
import config from 'accent-webapp/config/environment';
import {tracked} from '@glimmer/tracking';

export default class LoginForms extends Component {
  @tracked
  username = '';

  googleUrl = `${config.API.AUTHENTICATION_PATH}/google`;
  githubUrl = `${config.API.AUTHENTICATION_PATH}/github`;
  slackUrl = `${config.API.AUTHENTICATION_PATH}/slack`;
  discordUrl = `${config.API.AUTHENTICATION_PATH}/discord`;

  get providerIds() {
    return this.providers.map(({id}) => id);
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

  get slackLoginEnabled() {
    return this.providerIds.includes('slack');
  }

  get discordLoginEnabled() {
    return this.providerIds.includes('discord');
  }

  get dummyUrl() {
    return `${config.API.AUTHENTICATION_PATH}/dummy/callback?email=${
      this.username
    }`;
  }
}
