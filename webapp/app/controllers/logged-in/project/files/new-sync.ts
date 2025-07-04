import {service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly} from '@ember/object/computed';
import Controller from '@ember/controller';
import Peeker from 'accent-webapp/services/peeker';
import Syncer from 'accent-webapp/services/syncer';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import GlobalState from 'accent-webapp/services/global-state';
import RouterService from '@ember/routing/router-service';
import {tracked} from '@glimmer/tracking';

const FLASH_MESSAGE_CREATE_SUCCESS =
  'pods.document.sync.flash_messages.create_success';
const FLASH_MESSAGE_CREATE_ERROR =
  'pods.document.sync.flash_messages.create_error';

export default class NewSyncController extends Controller {
  @tracked
  model: any;

  @service('peeker')
  declare peeker: Peeker;

  @service('syncer')
  declare syncer: Syncer;

  @service('intl')
  declare intl: IntlService;

  @service('router')
  declare router: RouterService;

  @service('flash-messages')
  declare flashMessages: FlashMessages;

  @service('global-state')
  declare globalState: GlobalState;

  @readOnly('model.project')
  project: any;

  @readOnly('project.revisions')
  revisions: any;

  @readOnly('project.versions.entries')
  versions: any;

  @readOnly('project.documents.entries')
  documents: any;

  @readOnly('globalState.permissions')
  permissions: any;

  @tracked
  revisionOperations: any = null;

  @action
  closeModal() {
    this.send('onRefresh');
    this.router.transitionTo('logged-in.project.files', this.model.project.id);
  }

  @action
  cancelFile() {
    this.revisionOperations = null;
  }

  @action
  async peek({
    fileSource,
    documentFormat,
    documentPath,
    revision,
    version,
    syncType
  }: {
    fileSource: any;
    documentFormat: any;
    documentPath: any;
    revision: any;
    version: any;
    syncType: any;
  }) {
    const file = fileSource;
    const project = this.project;
    const revisions = this.revisions;

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
    documentPath,
    revision,
    version,
    syncType
  }: {
    fileSource: any;
    documentFormat: any;
    documentPath: any;
    revision: any;
    version: any;
    syncType: any;
  }) {
    const file = fileSource;
    const project = this.project;

    try {
      await this.syncer.sync({
        project,
        revision,
        file,
        version,
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
