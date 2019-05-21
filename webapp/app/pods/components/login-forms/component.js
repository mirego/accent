// Vendor
import Component from '@ember/component';
import {computed} from '@ember/object';
import config from 'accent-webapp/config/environment';

export default Component.extend({
  username: '',

  googleLoginEnabled: computed(() => config.AUTH_PROVIDERS.includes('google')),
  dummyLoginEnabled: computed(() => config.AUTH_PROVIDERS.includes('dummy')),
  githubLoginEnabled: computed(() => config.AUTH_PROVIDERS.includes('github')),
  slackLoginEnabled: computed(() => config.AUTH_PROVIDERS.includes('slack')),

  googleUrl: computed(() => `${config.API.AUTHENTICATION_PATH}/google`),
  githubUrl: computed(() => `${config.API.AUTHENTICATION_PATH}/github`),
  slackUrl: computed(() => `${config.API.AUTHENTICATION_PATH}/slack`),
  dummyUrl: computed('username', function() {
    return `${
      config.API.AUTHENTICATION_PATH
    }/dummy/callback?email=${this.username}`;
  })
});
