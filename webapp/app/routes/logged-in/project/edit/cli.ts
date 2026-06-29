import Route from '@ember/routing/route';

export default class CliRoute extends Route {
  model() {
    return this.modelFor('logged-in.project');
  }
}
