import Route from '@ember/routing/route';
import AddTranslationsController from 'accent-webapp/pods/logged-in/project/files/add-translations/controller';

export default class AddTranslationsRoute extends Route {
  model({fileId}: {fileId: string}) {
    return {
      projectModel: this.modelFor('logged-in.project'),
      fileModel: this.modelFor('logged-in.project.files'),
      fileId,
    };
  }

  resetController(controller: AddTranslationsController, isExiting: boolean) {
    if (isExiting) {
      controller.revisionOperations = null;
    }
  }
}
