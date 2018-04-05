import Route from '@ember/routing/route';
import RSVP from 'rsvp';

export default Route.extend({
  model({versionId}) {
    return RSVP.hash({
      projectModel: this.modelFor('logged-in.project'),
      versionModel: this.modelFor('logged-in.project.versions'),
      versionId
    });
  }
});
