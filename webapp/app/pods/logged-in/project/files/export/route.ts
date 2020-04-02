import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import Exporter from 'accent-webapp/services/exporter';
import ExportController from 'accent-webapp/pods/logged-in/project/files/export/controller';

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
    orderByFilter: {
      refreshModel: true,
    },
  };

  model({fileId}: {fileId: string}) {
    return {
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
