import Route from '@ember/routing/route';
import MachineTranslationsController from 'accent-webapp/controllers/logged-in/project/files/machine-translations';

export default class MachineTranslationsRoute extends Route {
  model({fileId}: {fileId: string}) {
    return {
      projectModel: this.modelFor('logged-in.project'),
      fileModel: this.modelFor('logged-in.project.files'),
      fileId,
    };
  }

  resetController(
    controller: MachineTranslationsController,
    isExiting: boolean
  ) {
    if (isExiting) {
      controller.translatedFileContent = '';
    }
  }
}
