import {equal, and, readOnly} from '@ember/object/computed';
import {computed} from '@ember/object';
import Controller from '@ember/controller';

export default Controller.extend({
  queryParams: ['query', 'page', 'document', 'version'],

  query: '',
  page: 1,
  document: null,
  version: null,

  translations: readOnly('model.project.revision.translations.entries'),
  emptyEntries: equal('translations', undefined),
  emptyQuery: equal('query', ''),
  showSkeleton: and('emptyEntries', 'model.loading', 'emptyQuery'),
  showLoading: and('emptyEntries', 'model.loading'),

  withSelectedTranslations: readOnly('model.selectedTranslationIds'),

  filteredTranslations: computed('withSelectedTranslations', 'model.project.revision.translations.entries', function() {
    if (!this.withSelectedTranslations) return this.translations;

    const ids = this.withSelectedTranslations.split(',');

    return this.translations.filter(translation => ids.includes(translation.id));
  }),

  actions: {
    changeQuery(query) {
      this.set('page', 1);
      this.set('query', query);
    },

    changeVersion(versionId) {
      this.set('page', 1);
      this.set('version', versionId);
    },

    changeDocument(documentId) {
      this.set('page', 1);
      this.set('document', documentId);
    },

    selectPage(page) {
      window.scrollTo(0, 0);
      this.set('page', page);
    }
  }
});
