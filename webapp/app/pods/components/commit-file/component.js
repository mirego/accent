import {computed} from '@ember/object';
import {inject as service} from '@ember/service';
import {equal} from '@ember/object/computed';
import Component from '@ember/component';

const DEFAULT_PROPERTIES = {
  isFileReading: false,
  isFileRead: false,
  isPeeking: false,
  isPeekingDone: false,
  isPeekingError: false,
  isCommiting: false,
  isCommitingDone: false,
  isCommitingError: false,

  file: null,
  fileSource: null,
  documentPath: null,
  documentFormat: 'json'
};

// Attributes
// permissions: Ember Object containing <permission>
// revisions: Array of <revision>
// documents: Array of <document>
// commitButtonText: String
// onFileCancel: Function
// onPeek: Function
// onCommit: Function
export default Component.extend({
  i18n: service('i18n'),
  globalState: service('global-state'),

  init(...args) {
    this._super(...args);

    this._initProperties();
  },

  mergeTypes: ['smart', 'passive', 'force'],
  mergeType: 'smart',
  syncTypes: ['smart', 'passive'],
  syncType: 'smart',

  revisionValue: computed('revision', 'revisions.[]', function() {
    return (
      this.mappedRevisions.find(({value}) => value === this.revision) ||
      this.mappedRevisions[0]
    );
  }),

  mappedRevisions: computed('revisions.[]', function() {
    return this.revisions.map(({id, language}) => ({
      label: language.name,
      value: id
    }));
  }),

  revision: computed('revisions.[]', function() {
    return this.revisions.find(revision => revision.isMaster);
  }),

  isMerge: equal('commitAction', 'merge'),
  isSync: equal('commitAction', 'sync'),

  documentFormatValue: computed(
    'documentFormat',
    'documentFormatOptions',
    function() {
      return this.documentFormatOptions.find(
        ({value}) => value === this.documentFormat
      );
    }
  ),

  documentFormatOptions: computed('globalState.documentFormats', function() {
    if (!this.globalState.documentFormats) return [];

    return this.globalState.documentFormats.map(({slug, name}) => ({
      value: slug,
      label: name
    }));
  }),

  existingDocumentPath: computed(
    'documentPath',
    'documents.[].path',
    function() {
      if (!this.documentPath) return false;
      if (!this.documents) return false;

      const path = this.documentPath.replace(/\..+/, '');

      return this.documents.find(document => document.path === path);
    }
  ),

  actions: {
    onSelectMergeType(mergeType) {
      this.set('mergeType', mergeType);
    },

    onSelectSyncType(syncType) {
      this.set('syncType', syncType);
    },

    onSelectRevision(revision) {
      this.set(
        'revision',
        this.revisions.find(({id}) => id === revision.value)
      );
      this.set('revisionValue', revision);
    },

    commit() {
      this._onCommiting();

      this.onCommit(
        this.getProperties(
          'fileSource',
          'documentPath',
          'documentFormat',
          'revision',
          'mergeType',
          'syncType'
        )
      )
        .then(this._onCommitingDone.bind(this))
        .catch(this._onCommitingError.bind(this));
    },

    peek() {
      this._onPeeking();

      this.onPeek(
        this.getProperties(
          'fileSource',
          'documentPath',
          'documentFormat',
          'revision',
          'mergeType',
          'syncType'
        )
      )
        .then(this._onPeekingDone.bind(this))
        .catch(this._onPeekingError.bind(this));
    },

    fileChange(files) {
      const fileSource = files[0];
      const filename = fileSource.name.split('.');
      const fileExtension = filename.pop();

      const documentPath = filename.join('.');
      const documentFormat = this._formatFromExtension(fileExtension);
      const isFileReading = true;
      const isFileRead = false;
      const reader = new FileReader();

      this.setProperties({
        fileSource,
        documentPath,
        isFileReading,
        isFileRead,
        documentFormat
      });

      reader.onload = this._fileRead.bind(this);
      reader.readAsText(files[0]);
    },

    fileCancel() {
      this.onFileCancel();

      this._initProperties();
    }
  },

  _formatFromExtension(fileExtension) {
    if (!this.globalState.documentFormats) return null;

    const documentFormatItem = this.globalState.documentFormats.find(
      ({extension}) => extension === fileExtension
    );

    return documentFormatItem
      ? documentFormatItem.slug
      : this.globalState.documentFormats[0].slug;
  },

  /**
   * Called after a file is read.
   *
   * @private
   * @method
   * @param {ProgressEvent} result Native progress event containing the file raw content and infos
   */
  _fileRead(file) {
    const isFileReading = false;
    const isFileRead = true;

    this.setProperties({
      isFileReading,
      isFileRead,
      file
    });

    this.send('peek');
  },

  _onCommiting() {
    this.setProperties({
      isCommiting: true,
      isCommitingDone: false,
      isCommitingError: false,
      isPeekingError: false
    });
  },

  _onCommitingDone() {
    this.setProperties({isCommiting: false, isCommitingDone: true});
  },

  _onCommitingError() {
    this.setProperties({isCommiting: false, isCommitingError: true});
  },

  _onPeeking() {
    this.setProperties({
      isPeeking: true,
      isPeekingDone: false,
      isPeekingError: false,
      isCommitingError: false
    });
  },

  _onPeekingDone() {
    this.setProperties({isPeeking: false, isPeekingDone: true});
  },

  _onPeekingError() {
    this.setProperties({isPeeking: false, isPeekingError: true});
  },

  _initProperties() {
    this.setProperties(DEFAULT_PROPERTIES);
  }
});
