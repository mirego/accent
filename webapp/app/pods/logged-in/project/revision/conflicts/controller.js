import {computed} from '@ember/object';
import {inject as service} from '@ember/service';
import {readOnly, equal, empty, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import translationCorrectQuery from 'accent-webapp/queries/correct-translation';
import correctAllRevisionQuery from 'accent-webapp/queries/correct-all-revision';

const FLASH_MESSAGE_REVISION_CORRECT_SUCCESS =
  'pods.project.conflicts.flash_messages.revision_correct_success';
const FLASH_MESSAGE_REVISION_CORRECT_ERROR =
  'pods.project.conflicts.flash_messages.revision_correct_error';
const FLASH_MESSAGE_CORRECT_SUCCESS =
  'pods.project.conflicts.flash_messages.correct_success';
const FLASH_MESSAGE_CORRECT_ERROR =
  'pods.project.conflicts.flash_messages.correct_error';

export default Controller.extend({
  intl: service('intl'),
  flashMessages: service(),
  apolloMutate: service('apollo-mutate'),
  globalState: service('global-state'),

  queryParams: ['reference', 'page', 'query', 'document'],

  fullscreen: false,
  query: '',
  reference: null,
  document: null,
  page: 1,

  permissions: readOnly('globalState.permissions'),
  revision: readOnly('model.project.revision'),
  revisions: readOnly('model.revisionModel.project.revisions'),

  emptyEntries: equal('model.translations.entries', undefined),
  emptyReference: empty('reference'),
  emptyDocument: empty('document'),
  emptyQuery: equal('query', ''),

  showLoading: and('emptyEntries', 'model.loading'),

  showSkeleton: and(
    'emptyEntries',
    'model.loading',
    'emptyQuery',
    'emptyReference',
    'emptyDocument'
  ),
  referenceRevisions: computed('model.revisionId', 'revisions', function() {
    if (!this.revisions) return [];

    return this.revisions.filter(
      revision => revision.id !== this.model.revisionId
    );
  }),

  referenceRevision: computed(
    'model.referenceRevisionId',
    'revisions',
    function() {
      if (!this.revisions || !this.model.referenceRevisionId) return;

      return this.revisions.find(
        revision => revision.id === this.model.referenceRevisionId
      );
    }
  ),

  actions: {
    deactivateFullscreen() {
      this.set('fullscreen', false);
    },

    correctConflict(conflict, text) {
      return this.apolloMutate
        .mutate({
          mutation: translationCorrectQuery,
          variables: {
            translationId: conflict.id,
            text
          }
        })
        .then(() =>
          this.flashMessages.success(this.intl.t(FLASH_MESSAGE_CORRECT_SUCCESS))
        )
        .catch(() =>
          this.flashMessages.error(this.intl.t(FLASH_MESSAGE_CORRECT_ERROR))
        );
    },

    correctAllConflicts() {
      return this.apolloMutate
        .mutate({
          mutation: correctAllRevisionQuery,
          variables: {revisionId: this.revision.id}
        })
        .then(() => {
          this.flashMessages.success(
            this.intl.t(FLASH_MESSAGE_REVISION_CORRECT_SUCCESS)
          );
          return this.send('refresh');
        })
        .catch(() =>
          this.flashMessages.error(
            this.intl.t(FLASH_MESSAGE_REVISION_CORRECT_ERROR)
          )
        );
    },

    changeQuery(query) {
      this.set('page', 1);
      this.set('query', query);
    },

    changeReference(reference) {
      this.set('reference', reference);
    },

    changeDocument(documentEntry) {
      this.set('page', 1);
      this.set('document', documentEntry);
    },

    selectPage(page) {
      window.scrollTo(0, 0);
      this.set('page', page);
    }
  }
});
