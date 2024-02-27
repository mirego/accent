import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';

import projectUpdateQuery from 'accent-webapp/queries/update-project';
import projectDeleteQuery from 'accent-webapp/queries/delete-project';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import GlobalState from 'accent-webapp/services/global-state';
import RouterService from '@ember/routing/router-service';

const FLASH_MESSAGE_PREFIX = 'pods.project.edit.flash_messages.';
const FLASH_MESSAGE_PROJECT_SUCCESS = `${FLASH_MESSAGE_PREFIX}update_success`;
const FLASH_MESSAGE_PROJECT_ERROR = `${FLASH_MESSAGE_PREFIX}update_error`;
const FLASH_MESSAGE_DELETE_PROJECT_SUCCESS = `${FLASH_MESSAGE_PREFIX}delete_success`;
const FLASH_MESSAGE_DELETE_PROJECT_ERROR = `${FLASH_MESSAGE_PREFIX}delete_error`;

export default class ProjectEditIndexController extends Controller {
  @service('intl')
  intl: IntlService;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('global-state')
  globalState: GlobalState;

  @service('router')
  router: RouterService;

  @readOnly('model.project')
  project: any;

  @readOnly('globalState.permissions')
  permissions: any;

  @equal('model.project.name', undefined)
  emptyData: boolean;

  @and('emptyData', 'model.loading')
  showLoading: boolean;

  @action
  async deleteProject() {
    const project = this.project;

    const response = await this.apolloMutate.mutate({
      mutation: projectDeleteQuery,
      variables: {
        projectId: project.id
      }
    });

    if (response.errors) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_DELETE_PROJECT_ERROR));
    } else {
      this.flashMessages.success(
        this.intl.t(FLASH_MESSAGE_DELETE_PROJECT_SUCCESS)
      );

      this.router.transitionTo('logged-in.projects');
    }

    return response;
  }

  @action
  async updateProject(projectAttributes: any) {
    const project = this.project;

    return this.mutateResource({
      mutation: projectUpdateQuery,
      successMessage: FLASH_MESSAGE_PROJECT_SUCCESS,
      errorMessage: FLASH_MESSAGE_PROJECT_ERROR,
      variables: {
        projectId: project.id,
        ...projectAttributes
      }
    });
  }

  private async mutateResource({
    mutation,
    variables,
    successMessage,
    errorMessage
  }: {
    mutation: any;
    variables: any;
    successMessage: string;
    errorMessage: string;
  }) {
    const response = await this.apolloMutate.mutate({
      mutation,
      variables,
      refetchQueries: ['ProjectEdit']
    });

    if (response.errors) {
      this.flashMessages.error(this.intl.t(errorMessage));
    } else {
      this.flashMessages.success(this.intl.t(successMessage));
    }

    return response;
  }
}
