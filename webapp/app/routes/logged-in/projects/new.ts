import Route from '@ember/routing/route';
import Controller from 'accent-webapp/controllers/logged-in/projects/new';

export default class ProjectsNewRoute extends Route {
  model() {
    return this.modelFor('logged-in.projects');
  }

  resetController(controller: Controller, isExiting: boolean) {
    if (isExiting) {
      controller.error = false;
    }
  }
}
