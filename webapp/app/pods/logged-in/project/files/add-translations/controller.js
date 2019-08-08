import {computed} from '@ember/object';
import {inject as service} from '@ember/service';
import {readOnly, reads} from '@ember/object/computed';
import Controller from '@ember/controller';

const FLASH_MESSAGE_CREATE_SUCCESS =
  'pods.document.merge.flash_messages.create_success';
const FLASH_MESSAGE_CREATE_ERROR =
  'pods.document.merge.flash_messages.create_error';

export default Controller.extend({
  peeker: service('peeker'),
  merger: service('merger'),
  globalState: service('global-state'),
  i18n: service(),
  flashMessages: service(),

  revisionOperations: null,

  permissions: readOnly('globalState.permissions'),
  project: reads('model.projectModel.project'),
  revisions: reads('project.revisions'),
  documents: reads('model.fileModel.documents.entries'),

  documentFormatItem: computed('document.format', function() {
    if (!this.globalState.documentFormats) return {};

    return this.globalState.documentFormats.find(
      ({slug}) => slug === this.document.format
    );
  }),

  document: computed('documents', 'model.fileId', function() {
    if (!this.documents) return;

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

    peek({fileSource, documentFormat, revision, mergeType}) {
      const file = fileSource;
      const {project} = this;
      const documentPath = this.document.path;

      return this.peeker
        .merge({
          project,
          revision,
          file,
          documentPath,
          documentFormat,
          mergeType
        })
        .then(revisionOperations =>
          this.set('revisionOperations', revisionOperations)
        );
    },

    merge({fileSource, revision, documentFormat, mergeType}) {
      const file = fileSource;
      const {project} = this;
      const documentPath = this.document.path;

      return this.merger
        .merge({
          project,
          revision,
          file,
          documentPath,
          documentFormat,
          mergeType
        })
        .then(() =>
          this.flashMessages.success(this.i18n.t(FLASH_MESSAGE_CREATE_SUCCESS))
        )
        .then(() => this.send('closeModal'))
        .catch(() =>
          this.flashMessages.error(this.i18n.t(FLASH_MESSAGE_CREATE_ERROR))
        );
    }
  }
});
