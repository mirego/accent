import {computed} from '@ember/object';
import {inject as service} from '@ember/service';
import {readOnly, reads} from '@ember/object/computed';
import Controller from '@ember/controller';

const FLASH_MESSAGE_CREATE_SUCCESS = 'pods.document.sync.flash_messages.create_success';
const FLASH_MESSAGE_CREATE_ERROR = 'pods.document.sync.flash_messages.create_error';

export default Controller.extend({
  peeker: service('peeker'),
  syncer: service('syncer'),
  globalState: service('global-state'),
  i18n: service(),
  flashMessages: service(),

  permissions: readOnly('globalState.permissions'),
  project: reads('model.projectModel.project'),
  revisions: reads('project.revisions'),
  documents: reads('model.fileModel.documents.entries'),

  document: computed('documents', 'model.fileId', function() {
    return this.documents.find(({id}) => id === this.model.fileId);
  }),

  actions: {
    closeModal() {
      this.send('onRefresh');
      this.transitionToRoute('logged-in.project.files', this.project.id);
    },

    cancelFile() {
      this.set('revisionOperations', null);
    },

    peek({fileSource, documentFormat, revision, syncType}) {
      const file = fileSource;
      const {project, revisions} = this;
      const documentPath = this.document.path;

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
        .then(revisionOperations => this.set('revisionOperations', revisionOperations));
    },

    sync({fileSource, documentFormat, revision, syncType}) {
      const file = fileSource;
      const {project} = this;
      const documentPath = this.document.path;

      return this.syncer
        .sync({project, revision, file, documentPath, documentFormat, syncType})
        .then(() => this.flashMessages.success(this.i18n.t(FLASH_MESSAGE_CREATE_SUCCESS)))
        .then(() => this.send('closeModal'))
        .catch(() => this.flashMessages.error(this.i18n.t(FLASH_MESSAGE_CREATE_ERROR)));
    }
  }
});
