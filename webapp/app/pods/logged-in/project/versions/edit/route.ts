import Route from '@ember/routing/route';

export default class EditRoute extends Route {
  model({versionId}: {versionId: string}) {
    return {
      projectModel: this.modelFor('logged-in.project'),
      versionModel: this.modelFor('logged-in.project.versions'),
      versionId,
    };
  }
}
