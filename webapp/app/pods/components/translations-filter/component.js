import {computed, observer} from '@ember/object';
import {inject as service} from '@ember/service';
import {reads, gt} from '@ember/object/computed';
import Component from '@ember/component';
import {run} from '@ember/runloop';

const DEBOUNCE_OFFSET = 500; // ms

// Attributes:
// query: String
// document: Object <document>
// documents: Array of <document>
// version: Object <version>
// versions: Array of <version>
// onChangeQuery: Function
// onChangeDocument: Function
// onChangeVersion: Function
export default Component.extend({
  i18n: service(),

  debouncedQuery: reads('query'),
  showDocumentsSelect: gt('documents.length', 1),
  showVersionsSelect: gt('versions.length', 0),

  mappedDocuments: computed('documents.[]', function() {
    const documents = this.documents.map(({id, path}) => ({
      label: path,
      value: id
    }));

    documents.unshift({
      label: this.i18n.t('components.translations_filter.document_default_option_text'),
      value: null
    });

    return documents;
  }),

  documentValue: computed('document', 'mappedDocuments.[]', function() {
    return this.mappedDocuments.find(({value}) => value === this.document);
  }),

  mappedVersions: computed('versions.[]', function() {
    const versions = this.versions.map(({id, tag}) => ({
      label: tag,
      value: id
    }));

    versions.unshift({
      label: this.i18n.t('components.translations_filter.version_default_option_text'),
      value: null
    });

    return versions;
  }),

  versionValue: computed('version', 'mappedVersions.[]', function() {
    return this.mappedVersions.find(({value}) => value === this.version);
  }),

  queryDidChanges: observer('debouncedQuery', function() {
    run.debounce(this, this._debounceQuery, DEBOUNCE_OFFSET);
  }),

  _debounceQuery() {
    this.onChangeQuery(this.debouncedQuery);
  },

  actions: {
    submitForm() {
      this._debounceQuery();
    }
  }
});
