import {inject as service} from '@ember/service';
import {readOnly} from '@ember/object/computed';
import Controller from '@ember/controller';

const FLASH_MESSAGE_CREATE_SUCCESS =
  'pods.document.sync.flash_messages.create_success';
const FLASH_MESSAGE_CREATE_ERROR =
  'pods.document.sync.flash_messages.create_error';

export default Controller.extend({
  peeker: service('peeker'),
  syncer: service('syncer'),
  intl: service('intl'),
  flashMessages: service(),
  globalState: service('global-state'),

  project: readOnly('model.project'),
  revisions: readOnly('project.revisions'),
  documents: readOnly('project.documents.entries'),
  permissions: readOnly('globalState.permissions'),

  actions: {
    closeModal() {
      this.send('onRefresh');
      this.transitionToRoute('logged-in.project.files', this.model.project.id);
    },

    cancelFile() {
      this.set('revisionOperations', null);
    },

    peek({fileSource, documentFormat, documentPath, revision, syncType}) {
      const file = fileSource;
      const project = this.project;
      const revisions = this.revisions;

      return this.peeker
        .sync({
          project,
          revision,
          revisions,
          file,
          documentPath,
          documentFormat,
          syncType
        })
        .then(revisionOperations =>
          this.set('revisionOperations', revisionOperations)
        );
    },

    sync({fileSource, documentFormat, documentPath, revision, syncType}) {
      const file = fileSource;
      const project = this.project;

      return this.syncer
        .sync({project, revision, file, documentPath, documentFormat, syncType})
        .then(() =>
          this.flashMessages.success(this.intl.t(FLASH_MESSAGE_CREATE_SUCCESS))
        )
        .then(() => this.send('closeModal'))
        .catch(() =>
          this.flashMessages.error(this.intl.t(FLASH_MESSAGE_CREATE_ERROR))
        );
    }
  }
});
