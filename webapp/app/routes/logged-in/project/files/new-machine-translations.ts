import Route from '@ember/routing/route';
import NewMachineTranslationsController from 'accent-webapp/controllers/logged-in/project/files/new-machine-translations';

export default class NewMachineTranslationsRoute extends Route {
  resetController(
    controller: NewMachineTranslationsController,
    isExiting: boolean
  ) {
    if (isExiting) {
      controller.translatedFileContent = '';
    }
  }
}
