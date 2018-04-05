import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';

export default Route.extend({
  session: service('session'),

  redirect() {
    const newRoute = !this.session.credentials ? 'home' : 'logged-in.projects';

    this.transitionTo(newRoute);
  }
});
