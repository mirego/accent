import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import RSVP from 'rsvp';
import raven from 'npm:raven-js';
import config from 'accent-webapp/config/environment';

export default Route.extend({
  session: service('session'),

  beforeModel() {
    raven.config(config.SENTRY.DSN).install();

    return new RSVP.Promise(resolve => {
      if (!window.gapi || !config.GOOGLE_LOGIN_ENABLED) return resolve();

      window.gapi.load('auth2', () => {
        const auth2 = window.gapi.auth2.init({
          client_id: config.GOOGLE_API.CLIENT_ID, // eslint-disable-line camelcase
          cookiepolicy: 'single_host_origin'
        });

        this.set('session.googleAuth', auth2);
        resolve();
      });
    });
  }
});
