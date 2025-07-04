import {service} from '@ember/service';
import {action} from '@ember/object';
import Controller from '@ember/controller';
import RouterService from '@ember/routing/router-service';
import MachineTranslations from 'accent-webapp/services/machine-translations';
import {tracked} from '@glimmer/tracking';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import IntlService from 'ember-intl/services/intl';

const FLASH_MESSAGE_CREATE_ERROR =
  'pods.document.machine_translations.flash_messages.translate_error';

export default class NewMachineTranslationsController extends Controller {
  @tracked
  model: any;

  @service('router')
  declare router: RouterService;

  @service('machine-translations')
  declare machineTranslations: MachineTranslations;

  @service('flash-messages')
  declare flashMessages: FlashMessages;

  @service('intl')
  declare intl: IntlService;

  @tracked
  translatedFileContent = '';

  @action
  closeModal() {
    this.router.transitionTo('logged-in.project.files.index');
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
    try {
      const content = await this.machineTranslations.translateFile({
        project: this.model.project,
        file,
        fromLanguage,
        toLanguage,
        documentFormat
      });
      this.translatedFileContent = content;
    } catch (error) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_CREATE_ERROR));
    }
  }
}
