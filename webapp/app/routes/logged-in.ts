import {service} from '@ember/service';
import Route from '@ember/routing/route';
import Raven from 'raven-js';
import Session from 'accent-webapp/services/session';
import RouterService from '@ember/routing/router-service';

export default class LoggedInRoute extends Route {
  @service('session')
  declare session: Session;

  @service('router')
  declare router: RouterService;

  afterModel() {
    Raven.setUserContext(this.session.credentials.user);
  }

  redirect() {
    if (!this.session.isAuthenticated) {
      this.router.transitionTo('login');
    }
  }
}
