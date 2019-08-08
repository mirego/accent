// Vendor
import Component from '@ember/component';
import {computed} from '@ember/object';
import config from 'accent-webapp/config/environment';

export default Component.extend({
  username: '',
  providerIds: computed('providers.[].id', function() {
    return this.providers.map(({id}) => id);
  }),

  googleLoginEnabled: computed('providerIds', function() {
    return this.providerIds.includes('google');
  }),
  dummyLoginEnabled: computed('providerIds', function() {
    return this.providerIds.includes('dummy');
  }),
  githubLoginEnabled: computed('providerIds', function() {
    return this.providerIds.includes('github');
  }),
  slackLoginEnabled: computed('providerIds', function() {
    return this.providerIds.includes('slack');
  }),

  googleUrl: computed(() => `${config.API.AUTHENTICATION_PATH}/google`),
  githubUrl: computed(() => `${config.API.AUTHENTICATION_PATH}/github`),
  slackUrl: computed(() => `${config.API.AUTHENTICATION_PATH}/slack`),
  dummyUrl: computed('username', function() {
    return `${
      config.API.AUTHENTICATION_PATH
    }/dummy/callback?email=${this.username}`;
  })
});
