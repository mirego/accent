import {inject as service} from '@ember/service';
import {readOnly, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';

import translationUpdateQuery from 'accent-webapp/queries/update-translation';

const FLASH_MESSAGE_UPDATE_SUCCESS =
  'pods.translation.edit.flash_messages.update_success';
const FLASH_MESSAGE_UPDATE_ERROR =
  'pods.translation.edit.flash_messages.update_error';

export default Controller.extend({
  apolloMutate: service('apollo-mutate'),
  flashMessages: service(),
  intl: service('intl'),
  globalState: service('global-state'),

  permissions: readOnly('globalState.permissions'),
  emptyEntries: equal('model.relatedTranslations', undefined),
  showSkeleton: and('emptyEntries', 'model.loading'),

  actions: {
    updateTranslation(translation, text) {
      return this.apolloMutate
        .mutate({
          mutation: translationUpdateQuery,
          variables: {
            translationId: translation.id,
            text
          }
        })
        .then(() =>
          this.flashMessages.success(this.intl.t(FLASH_MESSAGE_UPDATE_SUCCESS))
        )
        .catch(() =>
          this.flashMessages.error(this.intl.t(FLASH_MESSAGE_UPDATE_ERROR))
        );
    }
  }
});
