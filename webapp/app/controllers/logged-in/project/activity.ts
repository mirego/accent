import {service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly} from '@ember/object/computed';
import Controller from '@ember/controller';
import {tracked} from '@glimmer/tracking';

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
  @tracked
  model: any;

  @service('intl')
  declare intl: IntlService;

  @service('flash-messages')
  declare flashMessages: FlashMessages;

  @service('apollo-mutate')
  declare apolloMutate: ApolloMutate;

  @service('global-state')
  declare globalState: GlobalState;

  queryParams = ['activitiesPage'];

  @readOnly('globalState.permissions')
  permissions: any;

  @action
  async rollback() {
    const response = await this.apolloMutate.mutate({
      mutation: operationRollbackQuery,
      variables: {
        operationId: this.model.activity.id
      }
    });

    if (response.errors) {
      this.flashMessages.error(
        this.intl.t(FLASH_MESSAGE_OPERATION_ROLLBACK_ERROR)
      );
    } else {
      this.flashMessages.success(
        this.intl.t(FLASH_MESSAGE_OPERATION_ROLLBACK_SUCCESS)
      );

      this.send('onRefresh');
    }
  }
}
