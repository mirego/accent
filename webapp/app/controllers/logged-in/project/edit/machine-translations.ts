import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import IntlService from 'ember-intl/services/intl';
import GlobalState from 'accent-webapp/services/global-state';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';

import machineTranslationsConfigSaveQuery, {
  SaveProjectMachineTranslationsConfigVariables
} from 'accent-webapp/queries/save-project-machine-translations-config';
import machineTranslationsConfigDeleteQuery from 'accent-webapp/queries/delete-project-machine-translations-config';

const FLASH_MESSAGE_PREFIX = 'pods.project.edit.flash_messages.';
const FLASH_MESSAGE_CONFIG_SUCCESS = `${FLASH_MESSAGE_PREFIX}machine_translations_config_success`;
const FLASH_MESSAGE_CONFIG_ERROR = `${FLASH_MESSAGE_PREFIX}machine_translations_config_error`;
const FLASH_MESSAGE_CONFIG_REMOVE_SUCCESS = `${FLASH_MESSAGE_PREFIX}machine_translations_config_remove_success`;
const FLASH_MESSAGE_CONFIG_REMOVE_ERROR = `${FLASH_MESSAGE_PREFIX}machine_translations_config_remove_error`;

export default class MachineTranslationController extends Controller {
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

  @readOnly('globalState.permissions')
  permissions: any;

  @equal('model.project.name', undefined)
  emptyData: boolean;

  @and('emptyData', 'model.loading')
  showLoading: boolean;

  @action
  async saveMachineTranslationsConfig(
    config: SaveProjectMachineTranslationsConfigVariables
  ) {
    return this.mutateResource({
      mutation: machineTranslationsConfigSaveQuery,
      successMessage: FLASH_MESSAGE_CONFIG_SUCCESS,
      errorMessage: FLASH_MESSAGE_CONFIG_ERROR,
      variables: {...config, projectId: this.project.id}
    });
  }

  @action
  async deleteMachineTranslationsConfig() {
    return this.mutateResource({
      mutation: machineTranslationsConfigDeleteQuery,
      successMessage: FLASH_MESSAGE_CONFIG_REMOVE_SUCCESS,
      errorMessage: FLASH_MESSAGE_CONFIG_REMOVE_ERROR,
      variables: {projectId: this.project.id}
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
      refetchQueries: ['Project', 'ProjectMachineTranslationsConfig']
    });

    if (response.errors) {
      this.flashMessages.error(this.intl.t(errorMessage));
    } else {
      this.flashMessages.success(this.intl.t(successMessage));
    }

    return response;
  }
}
