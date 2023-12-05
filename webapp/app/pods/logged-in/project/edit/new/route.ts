import Route from '@ember/routing/route';

export default class AzurePushRoute extends Route {
  model() {
    return {
      projectModel: this.modelFor('logged-in.project'),
    };
  }
}
