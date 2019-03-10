import {computed} from '@ember/object';
import {inject as service} from '@ember/service';
import {reads, empty} from '@ember/object/computed';
import Controller from '@ember/controller';

export default Controller.extend({
  fileSaver: service('file-saver'),
  globalState: service('global-state'),

  queryParams: ['revisionFilter', 'documentFormatFilter', 'orderByFilter'],

  exportLoading: true,
  fileRender: null,
  documentFormatFilter: null,
  orderByFilter: null,
  revisionFilter: null,

  project: reads('model.projectModel.project'),
  revisions: reads('project.revisions'),
  documents: reads('model.fileModel.documents.entries'),
  showLoading: reads('model.fileModel.loading'),
  exportButtonDisabled: empty('fileRender'),

  revision: computed('revisions', 'revisionFilter', function() {
    if (!this.revisions) return;

    return this.revisions.find(({id}) => id === this.revisionFilter);
  }),

  document: computed('documents', 'model.fileId', function() {
    if (!this.documents) return;

    return this.documents.find(({id}) => id === this.model.fileId);
  }),

  documentFormatItem: computed('document.format', function() {
    if (!this.globalState.documentFormats) return {};

    return this.globalState.documentFormats.find(({slug}) => slug === this.document.format);
  }),

  fileExtension: computed('documentFormatFilter', 'document.format', function() {
    if (!this.globalState.documentFormats) return '';

    const format = this.documentFormatFilter || this.document.format;
    const documentFormatItem = this.globalState.documentFormats.find(({slug}) => slug === format);
    if (!documentFormatItem) return '';

    return documentFormatItem.extension;
  }),

  actions: {
    closeModal() {
      this.transitionToRoute('logged-in.project.files', this.project.id);
    },

    onFileLoaded(content) {
      this.set('fileRender', content);
      this.set('exportLoading', false);
    },

    exportFile() {
      const blob = new Blob([this.fileRender], {
        type: 'charset=utf-8'
      });
      const filename = `${this.document.path}.${this.fileExtension}`;

      this.fileSaver.saveAs(blob, filename);
    }
  }
});
