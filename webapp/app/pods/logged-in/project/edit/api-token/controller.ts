import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import IntlService from 'ember-intl/services/intl';
import GlobalState from 'accent-webapp/services/global-state';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';

import apiTokenCreateQuery from 'accent-webapp/queries/create-api-token';
import apiTokenRevokeQuery from 'accent-webapp/queries/revoke-api-token';

const FLASH_MESSAGE_PREFIX = 'pods.project.edit.api_token.flash_messages.';
const FLASH_MESSAGE_API_TOKEN_ADD_SUCCESS = `${FLASH_MESSAGE_PREFIX}api_token_add_success`;
const FLASH_MESSAGE_API_TOKEN_ADD_ERROR = `${FLASH_MESSAGE_PREFIX}api_token_add_error`;
const FLASH_MESSAGE_API_TOKEN_REVOKE_SUCCESS = `${FLASH_MESSAGE_PREFIX}api_token_revoke_success`;
const FLASH_MESSAGE_API_TOKEN_REVOKE_ERROR = `${FLASH_MESSAGE_PREFIX}api_token_revoke_error`;

export default class APITokenController extends Controller {
  @service('intl')
  intl: IntlService;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @service('global-state')
  globalState: GlobalState;

  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @readOnly('globalState.permissions')
  permissions: any;

  @readOnly('model.project')
  project: any;

  @readOnly('model.accessToken')
  accessToken: string;

  @readOnly('model.apiTokens')
  apiTokens: any;

  @equal('model.project.name', undefined)
  emptyData: boolean;

  @and('emptyData', 'model.loading')
  showLoading: boolean;

  @action
  async createApiToken({
    name,
    pictureUrl,
    permissions,
  }: {
    name: string;
    pictureUrl: string | null;
    permissions: string[];
  }) {
    const project = this.project;

    return this.mutateResource({
      mutation: apiTokenCreateQuery,
      successMessage: FLASH_MESSAGE_API_TOKEN_ADD_SUCCESS,
      errorMessage: FLASH_MESSAGE_API_TOKEN_ADD_ERROR,
      variables: {
        projectId: project.id,
        pictureUrl,
        name,
        permissions,
      },
    });
  }

  @action
  async revokeApiToken(apiToken: {id: string}) {
    return this.mutateResource({
      mutation: apiTokenRevokeQuery,
      successMessage: FLASH_MESSAGE_API_TOKEN_REVOKE_SUCCESS,
      errorMessage: FLASH_MESSAGE_API_TOKEN_REVOKE_ERROR,
      variables: {
        id: apiToken.id,
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
    const response = await this.apolloMutate.mutate({
      mutation,
      variables,
      refetchQueries: ['ProjectApiToken'],
    });

    if (response.errors) {
      this.flashMessages.error(this.intl.t(errorMessage));
    } else {
      this.flashMessages.success(this.intl.t(successMessage));
    }

    return response;
  }
}
