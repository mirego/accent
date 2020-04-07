import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';

import integrationCreateQuery from 'accent-webapp/queries/create-integration';
import integrationUpdateQuery from 'accent-webapp/queries/update-integration';
import integrationDeleteQuery from 'accent-webapp/queries/delete-integration';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import GlobalState from 'accent-webapp/services/global-state';

const FLASH_MESSAGE_PREFIX = 'pods.project.edit.flash_messages.';
const FLASH_MESSAGE_INTEGRATION_ADD_SUCCESS = `${FLASH_MESSAGE_PREFIX}integration_add_success`;
const FLASH_MESSAGE_INTEGRATION_ADD_ERROR = `${FLASH_MESSAGE_PREFIX}integration_add_error`;
const FLASH_MESSAGE_INTEGRATION_UPDATE_SUCCESS = `${FLASH_MESSAGE_PREFIX}integration_update_success`;
const FLASH_MESSAGE_INTEGRATION_UPDATE_ERROR = `${FLASH_MESSAGE_PREFIX}integration_update_error`;
const FLASH_MESSAGE_INTEGRATION_REMOVE_SUCCESS = `${FLASH_MESSAGE_PREFIX}integration_remove_success`;
const FLASH_MESSAGE_INTEGRATION_REMOVE_ERROR = `${FLASH_MESSAGE_PREFIX}integration_remove_error`;

export default class ServiceIntegrationsController extends Controller {
  @service('intl')
  intl: IntlService;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('global-state')
  globalState: GlobalState;

  @readOnly('model.project')
  project: any;

  @readOnly('globalState.permissions')
  permissions: any;

  @equal('model.project.name', undefined)
  emptyData: boolean;

  @and('emptyData', 'model.loading')
  showLoading: boolean;

  @action
  async createIntegration({
    data,
    events,
    service,
  }: {
    data: any;
    events: any;
    service: any;
  }) {
    const project = this.project;

    return this.mutateResource({
      mutation: integrationCreateQuery,
      successMessage: FLASH_MESSAGE_INTEGRATION_ADD_SUCCESS,
      errorMessage: FLASH_MESSAGE_INTEGRATION_ADD_ERROR,
      variables: {
        projectId: project.id,
        data,
        events,
        service,
      },
    });
  }

  @action
  async updateIntegration({
    integration,
    data,
    events,
    service,
  }: {
    integration: any;
    data: any;
    events: any;
    service: any;
  }) {
    return this.mutateResource({
      mutation: integrationUpdateQuery,
      successMessage: FLASH_MESSAGE_INTEGRATION_UPDATE_SUCCESS,
      errorMessage: FLASH_MESSAGE_INTEGRATION_UPDATE_ERROR,
      variables: {
        integrationId: integration.id,
        data,
        events,
        service,
      },
    });
  }

  @action
  async deleteIntegration(integration: any) {
    return this.mutateResource({
      mutation: integrationDeleteQuery,
      successMessage: FLASH_MESSAGE_INTEGRATION_REMOVE_SUCCESS,
      errorMessage: FLASH_MESSAGE_INTEGRATION_REMOVE_ERROR,
      variables: {
        integrationId: integration.id,
      },
    });
  }

  private async mutateResource({
    mutation,
    variables,
    successMessage,
    errorMessage,
  }: {
    mutation: any;
    variables: any;
    successMessage: string;
    errorMessage: string;
  }) {
    try {
      await this.apolloMutate.mutate({
        mutation,
        variables,
        refetchQueries: ['ProjectServiceIntegrations'],
      });

      this.flashMessages.success(this.intl.t(successMessage));

      return {errors: null};
    } catch (errors) {
      this.flashMessages.error(this.intl.t(errorMessage));

      return {errors};
    }
  }
}
