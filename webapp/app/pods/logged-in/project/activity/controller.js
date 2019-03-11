import {inject as service} from '@ember/service';
import {readOnly} from '@ember/object/computed';
import Controller from '@ember/controller';

import operationRollbackQuery from 'accent-webapp/queries/rollback-operation';

const FLASH_MESSAGE_OPERATION_ROLLBACK_SUCCESS =
  'pods.project.activities.flash_messages.rollback_success';
const FLASH_MESSAGE_OPERATION_ROLLBACK_ERROR =
  'pods.project.activities.flash_messages.rollback_error';

export default Controller.extend({
  i18n: service(),
  flashMessages: service(),
  apolloMutate: service('apollo-mutate'),
  globalState: service('global-state'),

  queryParams: ['activitiesPage'],

  permissions: readOnly('globalState.permissions'),

  actions: {
    rollback() {
      return this.apolloMutate
        .mutate({
          mutation: operationRollbackQuery,
          variables: {
            operationId: this.model.activity.id
          }
        })
        .then(() => {
          this.flashMessages.success(
            this.i18n.t(FLASH_MESSAGE_OPERATION_ROLLBACK_SUCCESS)
          );
          this.send('onRefresh');
        })
        .catch(() =>
          this.flashMessages.error(
            this.i18n.t(FLASH_MESSAGE_OPERATION_ROLLBACK_ERROR)
          )
        );
    }
  }
});
