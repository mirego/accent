import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly} from '@ember/object/computed';
import {tracked} from '@glimmer/tracking';
import Controller from '@ember/controller';
import IntlService from 'ember-intl/services/intl';
import GlobalState from 'accent-webapp/services/global-state';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import RouterService from '@ember/routing/router-service';

import promptUpdateQuery from 'accent-webapp/queries/update-project-prompt';

const FLASH_MESSAGE_PREFIX = 'pods.project.edit.flash_messages.';
const FLASH_MESSAGE_PROMPT_UPDATE_SUCCESS = `${FLASH_MESSAGE_PREFIX}prompts_update_success`;
const FLASH_MESSAGE_PROMPT_UPDATE_ERROR = `${FLASH_MESSAGE_PREFIX}prompts_update_error`;

export default class PromptsEditController extends Controller {
  @tracked
  model: any;

  @service('intl')
  intl: IntlService;

  @service('global-state')
  globalState: GlobalState;

  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @service('router')
  router: RouterService;

  @readOnly('model.projectModel.project')
  project: any;

  @tracked
  error = false;

  get prompt() {
    return this.model.promptsModel.project.prompts.find(
      (prompt: {id: string}) => prompt.id === this.model.promptId
    );
  }

  @action
  async update({
    content,
    name,
    quickAccess
  }: {
    name: string | null;
    content: string;
    quickAccess: string | null;
  }) {
    return this.mutateResource({
      mutation: promptUpdateQuery,
      successMessage: FLASH_MESSAGE_PROMPT_UPDATE_SUCCESS,
      errorMessage: FLASH_MESSAGE_PROMPT_UPDATE_ERROR,
      variables: {id: this.prompt.id, content, name, quickAccess}
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
    this.error = false;

    const response = await this.apolloMutate.mutate({
      mutation,
      variables
    });

    if (response.errors) {
      this.error = true;
      this.flashMessages.error(this.intl.t(errorMessage));
    } else {
      this.router.transitionTo(
        'logged-in.project.edit.prompts',
        this.project.id
      );
      this.flashMessages.success(this.intl.t(successMessage));
    }

    return response;
  }

  @action
  closeModal() {
    this.router.transitionTo('logged-in.project.edit.prompts', this.project.id);
  }
}
