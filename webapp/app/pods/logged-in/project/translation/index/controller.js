import {inject as service} from '@ember/service';
import {readOnly} from '@ember/object/computed';
import Controller from '@ember/controller';
import translationCorrectQuery from 'accent-webapp/queries/correct-translation';
import translationUncorrectQuery from 'accent-webapp/queries/uncorrect-translation';
import translationUpdateQuery from 'accent-webapp/queries/update-translation';

const FLASH_MESSAGE_CORRECT_SUCCESS =
  'pods.translation.edit.flash_messages.correct_success';
const FLASH_MESSAGE_CORRECT_ERROR =
  'pods.translation.edit.flash_messages.correct_error';

const FLASH_MESSAGE_UNCORRECT_SUCCESS =
  'pods.translation.edit.flash_messages.uncorrect_success';
const FLASH_MESSAGE_UNCORRECT_ERROR =
  'pods.translation.edit.flash_messages.uncorrect_error';

const FLASH_MESSAGE_UPDATE_SUCCESS =
  'pods.translation.edit.flash_messages.update_success';
const FLASH_MESSAGE_UPDATE_ERROR =
  'pods.translation.edit.flash_messages.update_error';

export default Controller.extend({
  apolloMutate: service('apollo-mutate'),
  globalState: service('global-state'),
  i18n: service(),
  flashMessages: service(),

  permissions: readOnly('globalState.permissions'),

  actions: {
    correctConflict(text) {
      const conflict = this.model.translation;

      return this.apolloMutate
        .mutate({
          mutation: translationCorrectQuery,
          variables: {
            translationId: conflict.id,
            text
          }
        })
        .then(() =>
          this.flashMessages.success(this.i18n.t(FLASH_MESSAGE_CORRECT_SUCCESS))
        )
        .catch(() =>
          this.flashMessages.error(this.i18n.t(FLASH_MESSAGE_CORRECT_ERROR))
        );
    },

    uncorrectConflict() {
      const conflict = this.model.translation;

      return this.apolloMutate
        .mutate({
          mutation: translationUncorrectQuery,
          variables: {
            translationId: conflict.id
          }
        })
        .then(() =>
          this.flashMessages.success(
            this.i18n.t(FLASH_MESSAGE_UNCORRECT_SUCCESS)
          )
        )
        .catch(() =>
          this.flashMessages.error(this.i18n.t(FLASH_MESSAGE_UNCORRECT_ERROR))
        );
    },

    updateText(text) {
      const translation = this.model.translation;

      return this.apolloMutate
        .mutate({
          mutation: translationUpdateQuery,
          variables: {
            translationId: translation.id,
            text
          }
        })
        .then(() =>
          this.flashMessages.success(this.i18n.t(FLASH_MESSAGE_UPDATE_SUCCESS))
        )
        .catch(() =>
          this.flashMessages.error(this.i18n.t(FLASH_MESSAGE_UPDATE_ERROR))
        );
    }
  }
});
