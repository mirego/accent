import {inject as service} from '@ember/service';
import {reads, readOnly, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';

import collaboratorCreateQuery from 'accent-webapp/queries/create-collaborator';
import collaboratorDeleteQuery from 'accent-webapp/queries/delete-collaborator';
import collaboratorUpdateQuery from 'accent-webapp/queries/update-collaborator';

const FLASH_MESSAGE_PREFIX = 'pods.project.edit.flash_messages.';
const FLASH_MESSAGE_COLLABORATOR_ADD_SUCCESS = `${FLASH_MESSAGE_PREFIX}collaborator_add_success`;
const FLASH_MESSAGE_COLLABORATOR_ADD_ERROR = `${FLASH_MESSAGE_PREFIX}collaborator_add_error`;
const FLASH_MESSAGE_COLLABORATOR_REMOVE_SUCCESS = `${FLASH_MESSAGE_PREFIX}collaborator_remove_success`;
const FLASH_MESSAGE_COLLABORATOR_REMOVE_ERROR = `${FLASH_MESSAGE_PREFIX}collaborator_remove_error`;
const FLASH_MESSAGE_COLLABORATOR_UPDATE_SUCCESS = `${FLASH_MESSAGE_PREFIX}collaborator_update_success`;
const FLASH_MESSAGE_COLLABORATOR_UPDATE_ERROR = `${FLASH_MESSAGE_PREFIX}collaborator_update_error`;

export default Controller.extend({
  intl: service('intl'),
  flashMessages: service(),
  apolloMutate: service('apollo-mutate'),
  globalState: service('global-state'),

  project: reads('model.project'),
  collaborators: reads('project.collaborators'),

  permissions: readOnly('globalState.permissions'),

  emptyData: equal('model.project.name', undefined),
  showLoading: and('emptyData', 'model.loading'),

  actions: {
    createCollaborator({email, role}) {
      const project = this.project;

      return this._mutateResource({
        mutation: collaboratorCreateQuery,
        successMessage: FLASH_MESSAGE_COLLABORATOR_ADD_SUCCESS,
        errorMessage: FLASH_MESSAGE_COLLABORATOR_ADD_ERROR,
        variables: {
          projectId: project.id,
          email,
          role
        }
      });
    },

    updateCollaborator(collaborator, {role}) {
      return this._mutateResource({
        mutation: collaboratorUpdateQuery,
        successMessage: FLASH_MESSAGE_COLLABORATOR_UPDATE_SUCCESS,
        errorMessage: FLASH_MESSAGE_COLLABORATOR_UPDATE_ERROR,
        variables: {
          collaboratorId: collaborator.id,
          role
        }
      });
    },

    deleteCollaborator(collaborator) {
      return this._mutateResource({
        mutation: collaboratorDeleteQuery,
        successMessage: FLASH_MESSAGE_COLLABORATOR_REMOVE_SUCCESS,
        errorMessage: FLASH_MESSAGE_COLLABORATOR_REMOVE_ERROR,
        variables: {
          collaboratorId: collaborator.id
        }
      });
    }
  },

  _mutateResource({mutation, variables, successMessage, errorMessage}) {
    return this.apolloMutate
      .mutate({
        mutation,
        variables,
        refetchQueries: ['ProjectCollaborators']
      })
      .then(result => {
        this.flashMessages.success(this.intl.t(successMessage));
        return result;
      })
      .catch(result => {
        this.flashMessages.error(this.intl.t(errorMessage));
        return result;
      });
  }
});
