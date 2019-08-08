import Route from '@ember/routing/route';
import RSVP from 'rsvp';

export default Route.extend({
  model({revisionId}) {
    return RSVP.hash({
      revisionsModel: this.modelFor('logged-in.project.edit.manage-languages'),
      revisionId
    });
  }
});
