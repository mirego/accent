import Route from '@ember/routing/route';
import NewSyncController from 'accent-webapp/pods/logged-in/project/files/new-sync/controller';

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
