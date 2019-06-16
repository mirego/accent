import {inject as service} from '@ember/service';
import {not, readOnly, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import documentDeleteQuery from 'accent-webapp/queries/delete-document';
import documentUpdateQuery from 'accent-webapp/queries/update-document';

const FLASH_MESSAGE_DELETE_SUCCESS =
  'pods.document.index.flash_messages.delete_success';
const FLASH_MESSAGE_DELETE_ERROR =
  'pods.document.index.flash_messages.delete_error';
const FLASH_MESSAGE_UPDATE_SUCCESS =
  'pods.document.index.flash_messages.update_success';
const FLASH_MESSAGE_UPDATE_ERROR =
  'pods.document.index.flash_messages.update_error';

export default Controller.extend({
  i18n: service(),
  flashMessages: service(),
  apolloMutate: service('apollo-mutate'),
  globalState: service('global-state'),

  page: 1,

  emptyEntries: not('model.documents', undefined),
  permissions: readOnly('globalState.permissions'),
  showSkeleton: and('emptyEntries', 'model.loading'),

  actions: {
    deleteDocument(documentEntity) {
      return this.apolloMutate
        .mutate({
          mutation: documentDeleteQuery,
          variables: {
            documentId: documentEntity.id
          }
        })
        .then(() => {
          this.flashMessages.success(this.i18n.t(FLASH_MESSAGE_DELETE_SUCCESS));
          this.send('onRefresh');
        })
        .catch(() =>
          this.flashMessages.error(this.i18n.t(FLASH_MESSAGE_DELETE_ERROR))
        );
    },

    updateDocument(documentEntity, path) {
      return this.apolloMutate
        .mutate({
          mutation: documentUpdateQuery,
          variables: {
            documentId: documentEntity.id,
            path
          }
        })
        .then(() => {
          this.flashMessages.success(this.i18n.t(FLASH_MESSAGE_UPDATE_SUCCESS));
          this.send('onRefresh');
        })
        .catch(() =>
          this.flashMessages.error(this.i18n.t(FLASH_MESSAGE_UPDATE_ERROR))
        );
    },

    selectPage(page) {
      window.scroll(0, 0);
      this.set('page', page);
    }
  }
});
