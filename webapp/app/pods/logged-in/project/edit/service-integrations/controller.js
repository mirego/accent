import {inject as service} from '@ember/service';
import {reads, readOnly, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';

import integrationCreateQuery from 'accent-webapp/queries/create-integration';
import integrationUpdateQuery from 'accent-webapp/queries/update-integration';
import integrationDeleteQuery from 'accent-webapp/queries/delete-integration';

const FLASH_MESSAGE_PREFIX = 'pods.project.edit.flash_messages.';
const FLASH_MESSAGE_INTEGRATION_ADD_SUCCESS = `${FLASH_MESSAGE_PREFIX}integration_add_success`;
const FLASH_MESSAGE_INTEGRATION_ADD_ERROR = `${FLASH_MESSAGE_PREFIX}integration_add_error`;
const FLASH_MESSAGE_INTEGRATION_UPDATE_SUCCESS = `${FLASH_MESSAGE_PREFIX}integration_update_success`;
const FLASH_MESSAGE_INTEGRATION_UPDATE_ERROR = `${FLASH_MESSAGE_PREFIX}integration_update_error`;
const FLASH_MESSAGE_INTEGRATION_REMOVE_SUCCESS = `${FLASH_MESSAGE_PREFIX}integration_remove_success`;
const FLASH_MESSAGE_INTEGRATION_REMOVE_ERROR = `${FLASH_MESSAGE_PREFIX}integration_remove_error`;

export default Controller.extend({
  intl: service('intl'),
  flashMessages: service(),
  apolloMutate: service('apollo-mutate'),
  globalState: service('global-state'),

  project: reads('model.project'),

  permissions: readOnly('globalState.permissions'),

  emptyData: equal('model.project.name', undefined),
  showLoading: and('emptyData', 'model.loading'),

  actions: {
    createIntegration({data, events, service}) {
      const project = this.project;

      return this._mutateResource({
        mutation: integrationCreateQuery,
        successMessage: FLASH_MESSAGE_INTEGRATION_ADD_SUCCESS,
        errorMessage: FLASH_MESSAGE_INTEGRATION_ADD_ERROR,
        variables: {
          projectId: project.id,
          data,
          events,
          service
        }
      });
    },

    updateIntegration({integration, data, events, service}) {
      return this._mutateResource({
        mutation: integrationUpdateQuery,
        successMessage: FLASH_MESSAGE_INTEGRATION_UPDATE_SUCCESS,
        errorMessage: FLASH_MESSAGE_INTEGRATION_UPDATE_ERROR,
        variables: {
          integrationId: integration.id,
          data,
          events,
          service
        }
      });
    },

    deleteIntegration(integration) {
      return this._mutateResource({
        mutation: integrationDeleteQuery,
        successMessage: FLASH_MESSAGE_INTEGRATION_REMOVE_SUCCESS,
        errorMessage: FLASH_MESSAGE_INTEGRATION_REMOVE_ERROR,
        variables: {
          integrationId: integration.id
        }
      });
    }
  },

  _mutateResource({mutation, variables, successMessage, errorMessage}) {
    return this.apolloMutate
      .mutate({
        mutation,
        variables,
        refetchQueries: ['ProjectServiceIntegrations']
      })
      .then(() => this.flashMessages.success(this.intl.t(successMessage)))
      .catch(errors => {
        this.flashMessages.error(this.intl.t(errorMessage));
        return {errors};
      });
  }
});
