import {observer, computed} from '@ember/object';
import {inject as service} from '@ember/service';
import {notEmpty, gt, reads} from '@ember/object/computed';
import Component from '@ember/component';
import {run} from '@ember/runloop';

const DEBOUNCE_OFFSET = 500; // ms

// Attributes:
// query: String
// reference: String
// referenceRevisions: Array of <revision>
// document: Object <document>
// documents: Array of <document>
// onChangeQuery: Function
// onChangeReference: Function
// onChangeDocument: Function
export default Component.extend({
  i18n: service(),

  showReferenceRevisionsSelect: notEmpty('referenceRevisions'),
  showDocumentsSelect: gt('documents.length', 1),
  debouncedQuery: reads('query'),

  queryDidChanges: observer('debouncedQuery', function() {
    run.debounce(this, this._debounceQuery, DEBOUNCE_OFFSET);
  }),

  mappedDocuments: computed('documents.[]', function() {
    const documents = this.documents.map(({id, path}) => ({
      label: path,
      value: id
    }));

    documents.unshift({
      label: this.i18n.t(
        'components.conflicts_filters.document_default_option_text'
      ),
      value: null
    });

    return documents;
  }),

  mappedReferenceRevisions: computed('referenceRevisions.[]', function() {
    const revisions = this.referenceRevisions.map(({id, language}) => ({
      label: language.name,
      value: id
    }));

    revisions.unshift({
      label: this.i18n.t(
        'components.conflicts_filters.reference_default_option_text'
      ),
      value: null
    });

    return revisions;
  }),

  documentValue: computed('document', 'mappedDocuments.[]', function() {
    return this.mappedDocuments.find(({value}) => value === this.document);
  }),

  referenceValue: computed(
    'reference',
    'mappedReferenceRevisions.[]',
    function() {
      return this.mappedReferenceRevisions.find(
        ({value}) => value === this.reference
      );
    }
  ),

  _debounceQuery() {
    this.onChangeQuery(this.debouncedQuery);
  },

  actions: {
    submitForm() {
      this._debounceQuery();
    }
  }
});
