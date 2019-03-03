import {computed} from '@ember/object';
import {inject as service} from '@ember/service';
import {gt, notEmpty} from '@ember/object/computed';
import Component from '@ember/component';

// Attributes:
// orderBy: String
// format: String
// revision: String
// document: String
// onChangeOrderBy: Function
// onChangeFormat: Function
// onChangeRevision: Function
// onChangeDocument: Function
export default Component.extend({
  i18n: service('i18n'),
  globalState: service('global-state'),

  showOrders: notEmpty('onChangeOrderBy'),
  showRevisions: gt('mappedRevisions.length', 1),
  showDocuments: gt('mappedDocuments.length', 1),

  orderByValue: computed('orderBy', 'orderByOptions.[]', function() {
    return this.orderByOptions.find(({value}) => value === this.orderBy);
  }),

  orderByOptions: computed(() => {
    return [
      {
        value: null,
        label: 'components.revision_export_options.orders.original'
      },
      {value: 'key', label: 'components.revision_export_options.orders.az'}
    ];
  }),

  formatValue: computed('format', 'formatOptions', function() {
    return this.formatOptions.find(({value}) => value === this.format);
  }),

  formattedDocumentFormats: computed('globalState.documentFormats', function() {
    if (!this.globalState.documentFormats) return [];

    return this.globalState.documentFormats.map(({slug, name}) => ({
      value: slug,
      label: name
    }));
  }),

  formatOptions: computed('formattedDocumentFormats', function() {
    return [
      {
        value: null,
        label: this.i18n.t('components.revision_export_options.default_format')
      }
    ].concat(this.formattedDocumentFormats);
  }),

  revisionValue: computed('revision', 'mappedRevisions.[]', function() {
    return this.mappedRevisions.find(({value}) => value === this.revision) || this.mappedRevisions[0];
  }),

  mappedRevisions: computed('revisions.[]', function() {
    if (!this.revisions) return [];

    return this.revisions.map(({id, language}) => ({
      label: language.name,
      value: id
    }));
  }),

  documentValue: computed('document', 'mappedDocuments.[]', function() {
    return this.mappedDocuments.find(({value}) => value === this.document) || this.mappedDocuments[0];
  }),

  mappedDocuments: computed('documents.[]', function() {
    if (!this.documents) return [];

    return this.documents.map(({id, path}) => ({
      label: path,
      value: id
    }));
  }),

  actions: {
    orderByChanged(orderBy) {
      if (orderBy === this.orderBy) return;

      this.onChangeOrderBy(orderBy);
    },

    formatChanged(format) {
      if (format === this.format) return;

      this.onChangeFormat(format);
    },

    documentChanged(document) {
      if (document === this.document) return;

      this.onChangeDocument(document);
    },

    revisionChanged(revision) {
      if (revision === this.revision) return;

      this.onChangeRevision(revision);
    }
  }
});
