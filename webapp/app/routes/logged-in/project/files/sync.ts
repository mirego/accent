import Route from '@ember/routing/route';
import SyncController from 'accent-webapp/controllers/logged-in/project/files/sync';

export default class SyncRoute extends Route {
  model({fileId}: {fileId: string}) {
    return {
      projectModel: this.modelFor('logged-in.project'),
      fileModel: this.modelFor('logged-in.project.files'),
      fileId
    };
  }

  resetController(controller: SyncController, isExiting: boolean) {
    if (isExiting) {
      controller.revisionOperations = null;
    }
  }
}
