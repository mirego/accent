import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import Exporter from 'accent-webapp/services/exporter';
import JIPTController from 'accent-webapp/pods/logged-in/project/files/jipt/controller';

export default class JIPTRoute extends Route {
  @service('exporter')
  exporter: Exporter;

  queryParams = {
    documentFormatFilter: {
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

  resetController(controller: JIPTController, isExiting: boolean) {
    controller.exportLoading = true;

    if (isExiting) {
      controller.fileRender = null;
    }
  }
}
