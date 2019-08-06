import {inject as service} from '@ember/service';
import {reads, readOnly, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';

import projectUpdateQuery from 'accent-webapp/queries/update-project';
import projectDeleteQuery from 'accent-webapp/queries/delete-project';

const FLASH_MESSAGE_PREFIX = 'pods.project.edit.flash_messages.';
const FLASH_MESSAGE_PROJECT_SUCCESS = `${FLASH_MESSAGE_PREFIX}update_success`;
const FLASH_MESSAGE_PROJECT_ERROR = `${FLASH_MESSAGE_PREFIX}update_error`;
const FLASH_MESSAGE_DELETE_PROJECT_SUCCESS = `${FLASH_MESSAGE_PREFIX}delete_success`;
const FLASH_MESSAGE_DELETE_PROJECT_ERROR = `${FLASH_MESSAGE_PREFIX}delete_error`;

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
    deleteProject() {
      const project = this.project;

      return this.apolloMutate
        .mutate({
          mutation: projectDeleteQuery,
          variables: {
            projectId: project.id
          }
        })
        .then(() => {
          this.flashMessages.success(
            this.intl.t(FLASH_MESSAGE_DELETE_PROJECT_SUCCESS)
          );
          this.transitionToRoute('logged-in.projects');
        })
        .catch(() =>
          this.flashMessages.error(
            this.intl.t(FLASH_MESSAGE_DELETE_PROJECT_ERROR)
          )
        );
    },

    updateProject(projectAttributes) {
      const project = this.project;

      return this._mutateResource({
        mutation: projectUpdateQuery,
        successMessage: FLASH_MESSAGE_PROJECT_SUCCESS,
        errorMessage: FLASH_MESSAGE_PROJECT_ERROR,
        variables: {
          projectId: project.id,
          ...projectAttributes
        }
      });
    }
  },

  _mutateResource({mutation, variables, successMessage, errorMessage}) {
    return this.apolloMutate
      .mutate({
        mutation,
        variables,
        refetchQueries: ['ProjectEdit']
      })
      .then(() => this.flashMessages.success(this.intl.t(successMessage)))
      .catch(() => this.flashMessages.error(this.intl.t(errorMessage)));
  }
});
