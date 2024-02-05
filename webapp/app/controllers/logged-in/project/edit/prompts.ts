import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import IntlService from 'ember-intl/services/intl';
import GlobalState from 'accent-webapp/services/global-state';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';

import promptConfigSaveQuery, {
  SaveProjectPromptConfigVariables,
} from 'accent-webapp/queries/save-project-prompt-config';
import promptConfigDeleteQuery from 'accent-webapp/queries/delete-project-prompt-config';
import promptDeleteQuery from 'accent-webapp/queries/delete-project-prompt';
import projectPromptConfigQuery, {
  ProjectPromptConfigResponse,
} from 'accent-webapp/queries/project-prompt-config';
import {InMemoryCache} from 'apollo-boost';

const FLASH_MESSAGE_PREFIX = 'pods.project.edit.flash_messages.';
const FLASH_MESSAGE_CONFIG_SUCCESS = `${FLASH_MESSAGE_PREFIX}prompts_config_success`;
const FLASH_MESSAGE_CONFIG_ERROR = `${FLASH_MESSAGE_PREFIX}prompts_config_error`;
const FLASH_MESSAGE_CONFIG_REMOVE_SUCCESS = `${FLASH_MESSAGE_PREFIX}prompts_config_remove_success`;
const FLASH_MESSAGE_CONFIG_REMOVE_ERROR = `${FLASH_MESSAGE_PREFIX}prompts_config_remove_error`;
const FLASH_MESSAGE_PROMPT_REMOVE_SUCCESS = `${FLASH_MESSAGE_PREFIX}prompts_remove_success`;
const FLASH_MESSAGE_PROMPT_REMOVE_ERROR = `${FLASH_MESSAGE_PREFIX}prompts_remove_error`;

export default class PromptsController extends Controller {
  @service('intl')
  intl: IntlService;

  @service('global-state')
  globalState: GlobalState;

  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @readOnly('model.project')
  project: any;

  @readOnly('model.prompts')
  prompts: any;

  @readOnly('globalState.permissions')
  permissions: any;

  @equal('model.project.name', undefined)
  emptyData: boolean;

  @and('emptyData', 'model.loading')
  showLoading: boolean;

  @action
  async savePromptConfig(config: SaveProjectPromptConfigVariables) {
    return this.mutateConfigResource({
      mutation: promptConfigSaveQuery,
      successMessage: FLASH_MESSAGE_CONFIG_SUCCESS,
      errorMessage: FLASH_MESSAGE_CONFIG_ERROR,
      variables: {...config, projectId: this.project.id},
    });
  }

  @action
  async deletePromptConfig() {
    return this.mutateConfigResource({
      mutation: promptConfigDeleteQuery,
      successMessage: FLASH_MESSAGE_CONFIG_REMOVE_SUCCESS,
      errorMessage: FLASH_MESSAGE_CONFIG_REMOVE_ERROR,
      variables: {projectId: this.project.id},
    });
  }

  @action
  async deletePrompt(promptId: string) {
    return this.mutateResource({
      mutation: promptDeleteQuery,
      successMessage: FLASH_MESSAGE_PROMPT_REMOVE_SUCCESS,
      errorMessage: FLASH_MESSAGE_PROMPT_REMOVE_ERROR,
      variables: {promptId},
    });
  }

  private async mutateConfigResource({
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
    const response = await this.apolloMutate.mutate({
      mutation,
      variables,
      refetchQueries: ['Project', 'ProjectPromptConfig'],
    });

    if (response.errors) {
      this.flashMessages.error(this.intl.t(errorMessage));
    } else {
      this.flashMessages.success(this.intl.t(successMessage));
    }

    return response;
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
    const response = await this.apolloMutate.mutate({
      mutation,
      variables,
      refetchQueries: ['Project'],
      update: (cache: InMemoryCache) => {
        const data = cache.readQuery({
          query: projectPromptConfigQuery,
          variables: {projectId: this.project.id},
        }) as ProjectPromptConfigResponse;

        const prompts = data.viewer.project.prompts.filter(
          (prompt) => prompt.id !== variables.promptId
        );
        data.viewer.project.prompts = prompts;

        cache.writeQuery({
          query: projectPromptConfigQuery,
          variables: {projectId: this.project.id},
          data,
        });
      },
    });

    if (response.errors) {
      this.flashMessages.error(this.intl.t(errorMessage));
    } else {
      this.flashMessages.success(this.intl.t(successMessage));
    }

    return response;
  }
}
