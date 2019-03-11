import {inject as service} from '@ember/service';
import {readOnly, reads, equal, and} from '@ember/object/computed';
import {computed} from '@ember/object';
import Controller from '@ember/controller';
import correctAllRevisionQuery from 'accent-webapp/queries/correct-all-revision';
import uncorrectAllRevisionQuery from 'accent-webapp/queries/uncorrect-all-revision';

const FLASH_MESSAGE_REVISION_CORRECT_SUCCESS =
  'pods.project.index.flash_messages.revision_correct_success';
const FLASH_MESSAGE_REVISION_CORRECT_ERROR =
  'pods.project.index.flash_messages.revision_correct_error';
const FLASH_MESSAGE_REVISION_UNCORRECT_SUCCESS =
  'pods.project.index.flash_messages.revision_uncorrect_success';
const FLASH_MESSAGE_REVISION_UNCORRECT_ERROR =
  'pods.project.index.flash_messages.revision_uncorrect_error';

export default Controller.extend({
  globalState: service('global-state'),
  apolloMutate: service('apollo-mutate'),
  flashMessages: service(),
  i18n: service(),

  permissions: readOnly('globalState.permissions'),
  project: reads('model.project'),
  revisions: reads('project.revisions'),
  emptyProject: equal('model.project', undefined),
  showLoading: and('emptyProject', 'model.loading'),

  document: computed('project.documents.entries.[]', function() {
    return this.project.documents.entries[0];
  }),

  actions: {
    correctAllConflicts(revision) {
      return this.apolloMutate
        .mutate({
          mutation: correctAllRevisionQuery,
          variables: {revisionId: revision.id}
        })
        .then(() =>
          this.flashMessages.success(
            this.i18n.t(FLASH_MESSAGE_REVISION_CORRECT_SUCCESS)
          )
        )
        .catch(() =>
          this.flashMessages.error(
            this.i18n.t(FLASH_MESSAGE_REVISION_CORRECT_ERROR)
          )
        );
    },

    uncorrectAllConflicts(revision) {
      return this.apolloMutate
        .mutate({
          mutation: uncorrectAllRevisionQuery,
          variables: {revisionId: revision.id}
        })
        .then(() =>
          this.flashMessages.success(
            this.i18n.t(FLASH_MESSAGE_REVISION_UNCORRECT_SUCCESS)
          )
        )
        .catch(() =>
          this.flashMessages.error(
            this.i18n.t(FLASH_MESSAGE_REVISION_UNCORRECT_ERROR)
          )
        );
    }
  }
});
