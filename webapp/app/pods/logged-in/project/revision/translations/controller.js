import {inject as service} from '@ember/service';
import {equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import translationUpdateQuery from 'accent-webapp/queries/update-translation';

const FLASH_MESSAGE_UPDATE_SUCCESS = 'pods.translation.edit.flash_messages.update_success';
const FLASH_MESSAGE_UPDATE_ERROR = 'pods.translation.edit.flash_messages.update_error';

export default Controller.extend({
  apolloMutate: service('apollo-mutate'),
  globalState: service('global-state'),
  i18n: service(),
  flashMessages: service(),

  queryParams: ['query', 'page', 'document', 'version'],

  query: '',
  page: 1,
  document: null,
  version: null,

  emptyEntries: equal('model.translations.entries', undefined),
  emptyQuery: equal('query', ''),
  showSkeleton: and('emptyEntries', 'model.loading', 'emptyQuery'),
  showLoading: and('emptyEntries', 'model.loading'),

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
    },

    updateText(translation, text) {
      return this.apolloMutate
        .mutate({
          mutation: translationUpdateQuery,
          variables: {
            translationId: translation.id,
            text
          }
        })
        .then(() => this.flashMessages.success(this.i18n.t(FLASH_MESSAGE_UPDATE_SUCCESS)))
        .catch(() => this.flashMessages.error(this.i18n.t(FLASH_MESSAGE_UPDATE_ERROR)));
    }
  }
});
