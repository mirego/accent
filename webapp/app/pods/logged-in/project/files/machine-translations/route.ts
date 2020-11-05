import Route from '@ember/routing/route';
import MachineTranslationsController from 'accent-webapp/pods/logged-in/project/files/machine-translations/controller';

export default class MachineTranslationsRoute extends Route {
  resetController(
    controller: MachineTranslationsController,
    isExiting: boolean
  ) {
    if (isExiting) {
      controller.translatedFileContent = '';
    }
  }
}
