import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import Raven from 'npm:raven-js';
import AuthenticatedRoute from 'accent-webapp/mixins/authenticated-route';

export default Route.extend(AuthenticatedRoute, {
  session: service('session'),

  afterModel() {
    Raven.setUserContext(this.session.credentials.user);
  }
});
