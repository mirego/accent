import Route from '@ember/routing/route';
import NewController from 'accent-webapp/controllers/logged-in/project/versions/new';

export default class NewRoute extends Route {
  model() {
    return this.modelFor('logged-in.project');
  }

  resetController(controller: NewController, isExiting: boolean) {
    if (isExiting) {
      controller.error = false;
    }
  }
}
