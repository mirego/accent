import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import RSVP from 'rsvp';

export default Route.extend({
  exporter: service('exporter'),

  queryParams: {
    revisionFilter: {
      refreshModel: true
    },
    documentFormatFilter: {
      refreshModel: true
    },
    orderByFilter: {
      refreshModel: true
    }
  },

  model({fileId}) {
    return RSVP.hash({
      projectModel: this.modelFor('logged-in.project'),
      fileModel: this.modelFor('logged-in.project.files'),
      fileId
    });
  },

  resetController(controller, isExiting) {
    controller.set('exportLoading', true);

    if (isExiting) {
      controller.setProperties({
        fileRender: null
      });
    }
  }
});
