import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import Controller from '@ember/controller';
import RouterService from '@ember/routing/router-service';
import MachineTranslations from 'accent-webapp/services/machine-translations';
import {tracked} from '@glimmer/tracking';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import IntlService from 'ember-intl/services/intl';
import GlobalState from 'accent-webapp/services/global-state';

const FLASH_MESSAGE_CREATE_ERROR =
  'pods.document.machine_translations.flash_messages.translate_error';

export default class MachineTranslationsController extends Controller {
  @tracked
  model: any;

  @service('global-state')
  globalState: GlobalState;

  @service('router')
  router: RouterService;

  @service('machine-translations')
  machineTranslations: MachineTranslations;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @service('intl')
  intl: IntlService;

  @tracked
  translatedFileContent = '';

  get document() {
    return this.model.fileModel.documents.entries.find(
      (document: {id: string}) => document.id === this.model.fileId
    );
  }

  get documentFormatItem() {
    if (!this.globalState.documentFormats) return {};

    return this.globalState.documentFormats.find(
      ({slug}) => slug === this.document.format
    );
  }

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
    fromLanguage: string,
    toLanguage: string,
    documentFormat: string
  ) {
    try {
      const content = await this.machineTranslations.translateDocument({
        project: this.model.projectModel.project,
        documentId: this.model.fileId,
        fromLanguage,
        toLanguage,
        documentFormat,
      });
      this.translatedFileContent = content;
    } catch (error) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_CREATE_ERROR));
    }
  }
}
