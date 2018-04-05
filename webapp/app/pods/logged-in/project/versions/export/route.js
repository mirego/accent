import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import RSVP from 'rsvp';

export default Route.extend({
  exporter: service('exporter'),

  queryParams: {
    revisionFilter: {
      refreshModel: true
    },
    documentFilter: {
      refreshModel: true
    },
    documentFormatFilter: {
      refreshModel: true
    },
    orderByFilter: {
      refreshModel: true
    }
  },

  model({versionId}) {
    return RSVP.hash({
      projectModel: this.modelFor('logged-in.project'),
      versionModel: this.modelFor('logged-in.project.versions'),
      versionId
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
