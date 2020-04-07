import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import Raven from 'raven-js';
import Session from 'accent-webapp/services/session';

export default class LoggedInRoute extends Route {
  @service('session')
  session: Session;

  afterModel() {
    Raven.setUserContext(this.session.credentials.user);
  }

  redirect() {
    if (!this.session.isAuthenticated) {
      this.transitionTo('login');
    }
  }
}
