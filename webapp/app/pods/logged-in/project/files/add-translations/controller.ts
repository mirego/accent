import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {readOnly} from '@ember/object/computed';
import Controller from '@ember/controller';
import Peeker from 'accent-webapp/services/peeker';
import Merger from 'accent-webapp/services/merger';
import GlobalState from 'accent-webapp/services/global-state';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import {tracked} from '@glimmer/tracking';
import RouterService from '@ember/routing/router-service';

const FLASH_MESSAGE_CREATE_SUCCESS =
  'pods.document.merge.flash_messages.create_success';
const FLASH_MESSAGE_CREATE_ERROR =
  'pods.document.merge.flash_messages.create_error';

export default class AddTranslationsController extends Controller {
  @service('peeker')
  peeker: Peeker;

  @service('merger')
  merger: Merger;

  @service('global-state')
  globalState: GlobalState;

  @service('intl')
  intl: IntlService;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @service('router')
  router: RouterService;

  @tracked
  revisionOperations: any = null;

  @readOnly('globalState.permissions')
  permissions: any;

  @readOnly('model.projectModel.project')
  project: any;

  @readOnly('project.revisions')
  revisions: any;

  @readOnly('model.fileModel.documents.entries')
  documents: any;

  get documentFormatItem() {
    if (!this.globalState.documentFormats) return {};

    return this.globalState.documentFormats.find(({slug}) => {
      return slug === this.document.format;
    });
  }

  get document() {
    if (!this.documents) return;

    return this.documents.find(
      ({id}: {id: string}) => id === this.model.fileId
    );
  }

  @action
  closeModal() {
    this.send('onRefresh');

    this.router.transitionTo('logged-in.project.files', this.project.id);
  }

  @action
  cancelFile() {
    this.revisionOperations = null;
  }

  @action
  async peek({
    fileSource,
    documentFormat,
    revision,
    mergeType,
  }: {
    fileSource: any;
    documentFormat: any;
    revision: any;
    mergeType: any;
  }) {
    const file = fileSource;
    const project = this.project;
    const documentPath = this.document.path;

    const revisionOperations = await this.peeker.merge({
      project,
      revision,
      file,
      documentPath,
      documentFormat,
      mergeType,
    });

    this.revisionOperations = revisionOperations;
  }

  @action
  async merge({
    fileSource,
    revision,
    documentFormat,
    mergeType,
  }: {
    fileSource: any;
    revision: any;
    documentFormat: any;
    mergeType: any;
  }) {
    const file = fileSource;
    const project = this.project;
    const documentPath = this.document.path;

    try {
      await this.merger.merge({
        project,
        revision,
        file,
        documentPath,
        documentFormat,
        mergeType,
      });

      this.flashMessages.success(this.intl.t(FLASH_MESSAGE_CREATE_SUCCESS));
      this.send('closeModal');
    } catch (error) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_CREATE_ERROR));
    }
  }
}
