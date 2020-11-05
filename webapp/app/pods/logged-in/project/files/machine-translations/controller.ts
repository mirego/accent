import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import Controller from '@ember/controller';
import RouterService from '@ember/routing/router-service';
import MachineTranslations from 'accent-webapp/services/machine-translations';
import {tracked} from '@glimmer/tracking';

export default class MachineTranslationsController extends Controller {
  @service('router')
  router: RouterService;

  @service('machine-translations')
  machineTranslations: MachineTranslations;

  @tracked
  translatedFileContent = '';

  @action
  closeModal() {
    this.router.transitionTo('logged-in.project.files.index');
  }

  get languages() {
    return this.model.project.revisions.map(
      (revision: {language: any}) => revision.language
    );
  }

  @action
  resetContent() {
    this.translatedFileContent = '';
  }

  @action
  async translate(
    file: File,
    fromLanguage: string,
    toLanguage: string,
    documentFormat: string
  ) {
    const content = await this.machineTranslations.translateFile({
      project: this.model.project,
      file,
      fromLanguage,
      toLanguage,
      documentFormat,
    });
    this.translatedFileContent = content;
  }
}
