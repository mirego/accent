import Route from '@ember/routing/route';
import NewSyncController from 'accent-webapp/controllers/logged-in/project/files/new-sync';

export default class NewSyncRoute extends Route {
  model() {
    return this.modelFor('logged-in.project');
  }

  resetController(controller: NewSyncController, isExiting: boolean) {
    if (isExiting) {
      controller.revisionOperations = null;
    }
  }
}
