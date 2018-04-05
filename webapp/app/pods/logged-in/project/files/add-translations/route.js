import Route from '@ember/routing/route';
import RSVP from 'rsvp';

export default Route.extend({
  model({fileId}) {
    return RSVP.hash({
      projectModel: this.modelFor('logged-in.project'),
      fileModel: this.modelFor('logged-in.project.files'),
      fileId
    });
  },

  resetController(controller, isExiting) {
    if (isExiting) {
      controller.setProperties({
        revisionOperations: null
      });
    }
  }
});
