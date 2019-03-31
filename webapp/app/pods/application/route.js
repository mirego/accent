import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import raven from 'npm:raven-js';
import config from 'accent-webapp/config/environment';

export default Route.extend({
  session: service('session'),

  beforeModel() {
    raven.config(config.SENTRY.DSN).install();

    this._tryGoogleLoginAfterRedirect();
  },

  _tryGoogleLoginAfterRedirect() {
    if (!config.GOOGLE_LOGIN_ENABLED) return;

    const match = window.location.href
      .substring(window.location.href.indexOf('#') + 1)
      .split('&')
      .find(segment => segment.split('=')[0] === 'id_token');
    const token = match && match.split('=')[1];

    if (!token) return;

    this.session.login({token, provider: 'google'}).then(data => {
      if (data && data.token) this.transitionTo('logged-in.projects');
    });
  }
});
