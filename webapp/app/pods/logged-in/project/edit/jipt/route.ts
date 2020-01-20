import Route from '@ember/routing/route';

export default class JIPTRoute extends Route {
  model() {
    return this.modelFor('logged-in.project');
  }
}
