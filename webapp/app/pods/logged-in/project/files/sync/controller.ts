import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {readOnly} from '@ember/object/computed';
import Controller from '@ember/controller';
import Peeker from 'accent-webapp/services/peeker';
import Syncer from 'accent-webapp/services/syncer';
import GlobalState from 'accent-webapp/services/global-state';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import RouterService from '@ember/routing/router-service';
import {tracked} from '@glimmer/tracking';

const FLASH_MESSAGE_CREATE_SUCCESS =
  'pods.document.sync.flash_messages.create_success';
const FLASH_MESSAGE_CREATE_ERROR =
  'pods.document.sync.flash_messages.create_error';

export default class SyncController extends Controller {
  @service('peeker')
  peeker: Peeker;

  @service('syncer')
  syncer: Syncer;

  @service('global-state')
  globalState: GlobalState;

  @service('intl')
  intl: IntlService;

  @service('router')
  router: RouterService;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @readOnly('globalState.permissions')
  permissions: any;

  @readOnly('model.projectModel.project')
  project: any;

  @readOnly('project.revisions')
  revisions: any;

  @readOnly('model.fileModel.documents.entries')
  documents: any;

  @tracked
  revisionOperations: any = null;

  get documentFormatItem() {
    if (!this.globalState.documentFormats) return {};

    return this.globalState.documentFormats.find(({slug}) => {
      return slug === this.document.format;
    });
  }

  get document() {
    if (!this.documents) return;

    return this.documents.find(({id}: {id: string}) => {
      return id === this.model.fileId;
    });
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
    syncType,
  }: {
    fileSource: any;
    documentFormat: any;
    revision: any;
    syncType: any;
  }) {
    const file = fileSource;
    const {project, revisions} = this;
    const documentPath = this.document.path;

    const revisionOperations = await this.peeker.sync({
      project,
      revision,
      revisions,
      file,
      documentPath,
      documentFormat,
      syncType,
    });

    this.revisionOperations = revisionOperations;
  }

  @action
  async sync({
    fileSource,
    documentFormat,
    revision,
    syncType,
  }: {
    fileSource: any;
    documentFormat: any;
    revision: any;
    syncType: any;
  }) {
    const file = fileSource;
    const {project} = this;
    const documentPath = this.document.path;

    try {
      await this.syncer.sync({
        project,
        revision,
        file,
        documentPath,
        documentFormat,
        syncType,
      });

      this.flashMessages.success(this.intl.t(FLASH_MESSAGE_CREATE_SUCCESS));
      this.send('closeModal');
    } catch (error) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_CREATE_ERROR));
    }
  }
}
