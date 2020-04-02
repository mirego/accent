import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly} from '@ember/object/computed';
import Controller from '@ember/controller';

import operationRollbackQuery from 'accent-webapp/queries/rollback-operation';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import GlobalState from 'accent-webapp/services/global-state';

const FLASH_MESSAGE_OPERATION_ROLLBACK_SUCCESS =
  'pods.project.activities.flash_messages.rollback_success';
const FLASH_MESSAGE_OPERATION_ROLLBACK_ERROR =
  'pods.project.activities.flash_messages.rollback_error';

export default class ActivityController extends Controller {
  @service('intl')
  intl: IntlService;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('global-state')
  globalState: GlobalState;

  queryParams = ['activitiesPage'];

  @readOnly('globalState.permissions')
  permissions: any;

  @action
  async rollback() {
    try {
      await this.apolloMutate.mutate({
        mutation: operationRollbackQuery,
        variables: {
          operationId: this.model.activity.id,
        },
      });

      this.flashMessages.success(
        this.intl.t(FLASH_MESSAGE_OPERATION_ROLLBACK_SUCCESS)
      );

      this.send('onRefresh');
    } catch (error) {
      this.flashMessages.error(
        this.intl.t(FLASH_MESSAGE_OPERATION_ROLLBACK_ERROR)
      );
    }
  }
}
