import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import Exporter from 'accent-webapp/services/exporter';
import ExportController from 'accent-webapp/controllers/logged-in/project/files/export';
import Transition from '@ember/routing/transition';

export default class ExportRoute extends Route {
  @service('exporter')
  exporter: Exporter;

  queryParams = {
    revisionFilter: {
      refreshModel: true,
    },
    documentFormatFilter: {
      refreshModel: true,
    },
    versionFilter: {
      refreshModel: true,
    },
    orderByFilter: {
      refreshModel: true,
    },
    isTextEmpty: {
      refreshModel: true,
    },
    isAddedLastSync: {
      refreshModel: true,
    },
    isConflicted: {
      refreshModel: true,
    },
  };

  model({fileId}: {fileId: string}, transition: Transition) {
    return {
      from: transition.from,
      projectModel: this.modelFor('logged-in.project'),
      fileModel: this.modelFor('logged-in.project.files'),
      fileId,
    };
  }

  resetController(controller: ExportController, isExiting: boolean) {
    controller.exportLoading = true;

    if (isExiting) {
      controller.fileRender = null;
    }
  }
}
