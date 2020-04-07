import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import raven from 'raven-js';
import config from 'accent-webapp/config/environment';
import Session from 'accent-webapp/services/session';
import IntlService from 'ember-intl/services/intl';
import RouterService from '@ember/routing/router-service';

export default class ApplicationRoute extends Route {
  @service('session')
  session: Session;

  @service('intl')
  intl: IntlService;

  @service('router')
  router: RouterService;

  async beforeModel() {
    this.intl.setLocale('en-us');

    raven.config(config.SENTRY.DSN).install();

    await this.tryLoginAfterRedirect();
  }

  private async tryLoginAfterRedirect() {
    const match = window.location.search
      .substring(window.location.search.indexOf('?') + 1)
      .split('&')
      .find((segment) => segment.split('=')[0] === 'token');

    const token = match && match.split('=')[1];

    if (!token) return;

    const data = await this.session.login({token});

    if (data && data.user) {
      this.router.transitionTo('logged-in.projects');
    }
  }
}
