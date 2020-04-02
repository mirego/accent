import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import Exporter from 'accent-webapp/services/exporter';
import ExportController from 'accent-webapp/pods/logged-in/project/versions/export/controller';

export default class ExportRoute extends Route {
  @service('exporter')
  exporter: Exporter;

  queryParams = {
    revisionFilter: {
      refreshModel: true,
    },
    documentFilter: {
      refreshModel: true,
    },
    documentFormatFilter: {
      refreshModel: true,
    },
    orderByFilter: {
      refreshModel: true,
    },
  };

  model({versionId}: {versionId: string}) {
    return {
      projectModel: this.modelFor('logged-in.project'),
      versionModel: this.modelFor('logged-in.project.versions'),
      versionId,
    };
  }

  resetController(controller: ExportController, isExiting: boolean) {
    controller.exportLoading = true;

    if (isExiting) {
      controller.fileRender = null;
    }
  }
}
