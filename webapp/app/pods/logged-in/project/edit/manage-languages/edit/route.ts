import Route from '@ember/routing/route';

export default class ManageLanguagesEditController extends Route {
  model({revisionId}: {revisionId: string}) {
    return {
      revisionsModel: this.modelFor('logged-in.project.edit.manage-languages'),
      revisionId,
    };
  }
}
