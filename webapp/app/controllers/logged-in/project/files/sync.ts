import {action} from '@ember/object';
import {service} from '@ember/service';
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
  @tracked
  model: any;

  @service('peeker')
  declare peeker: Peeker;

  @service('syncer')
  declare syncer: Syncer;

  @service('global-state')
  declare globalState: GlobalState;

  @service('intl')
  declare intl: IntlService;

  @service('router')
  declare router: RouterService;

  @service('flash-messages')
  declare flashMessages: FlashMessages;

  @readOnly('globalState.permissions')
  permissions: any;

  @readOnly('model.projectModel.project')
  project: any;

  @readOnly('project.revisions')
  revisions: any;

  @readOnly('project.versions.entries')
  versions: any;

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
    version,
    syncType
  }: {
    fileSource: any;
    documentFormat: any;
    revision: any;
    version: any;
    syncType: any;
  }) {
    const file = fileSource;
    const {project, revisions} = this;
    const documentPath = this.document.path;

    const revisionOperations = await this.peeker.sync({
      project,
      revision,
      version,
      revisions,
      file,
      documentPath,
      documentFormat,
      syncType
    });

    this.revisionOperations = revisionOperations;
  }

  @action
  async sync({
    fileSource,
    documentFormat,
    revision,
    version,
    syncType
  }: {
    fileSource: any;
    documentFormat: any;
    revision: any;
    version: any;
    syncType: any;
  }) {
    const file = fileSource;
    const {project} = this;
    const documentPath = this.document.path;

    try {
      await this.syncer.sync({
        project,
        revision,
        version,
        file,
        documentPath,
        documentFormat,
        syncType
      });

      this.flashMessages.success(this.intl.t(FLASH_MESSAGE_CREATE_SUCCESS));
      this.send('closeModal');
    } catch (error) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_CREATE_ERROR));
    }
  }
}
