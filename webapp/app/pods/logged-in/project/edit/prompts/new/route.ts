import Route from '@ember/routing/route';

export default class PromptNewRoute extends Route {
  model() {
    return {
      projectModel: this.modelFor('logged-in.project'),
    };
  }
}
