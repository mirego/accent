import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import raven from 'raven-js';
import config from 'accent-webapp/config/environment';

export default Route.extend({
  session: service('session'),

  beforeModel() {
    raven.config(config.SENTRY.DSN).install();

    this._tryLoginAfterRedirect();
  },

  _tryLoginAfterRedirect() {
    const match = window.location.search
      .substring(window.location.search.indexOf('?') + 1)
      .split('&')
      .find(segment => segment.split('=')[0] === 'token');
    const token = match && match.split('=')[1];

    if (!token) return;

    this.session.login({token}).then(data => {
      if (data && data.user) this.transitionTo('logged-in.projects');
    });
  }
});
