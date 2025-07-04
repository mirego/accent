import {service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly} from '@ember/object/computed';
import {tracked} from '@glimmer/tracking';
import Controller from '@ember/controller';
import IntlService from 'ember-intl/services/intl';
import GlobalState from 'accent-webapp/services/global-state';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import RouterService from '@ember/routing/router-service';

import promptCreateQuery, {
  CreatePromptResponse
} from 'accent-webapp/queries/create-project-prompt';
import projectPromptConfigQuery from 'accent-webapp/queries/project-prompt-config';
import {InMemoryCache} from '@apollo/client/cache';

const FLASH_MESSAGE_PREFIX = 'pods.project.edit.flash_messages.';
const FLASH_MESSAGE_PROMPT_CREATE_SUCCESS = `${FLASH_MESSAGE_PREFIX}prompts_create_success`;
const FLASH_MESSAGE_PROMPT_CREATE_ERROR = `${FLASH_MESSAGE_PREFIX}prompts_create_error`;

export default class PromptsNewController extends Controller {
  @tracked
  model: any;

  @service('intl')
  declare intl: IntlService;

  @service('global-state')
  declare globalState: GlobalState;

  @service('apollo-mutate')
  declare apolloMutate: ApolloMutate;

  @service('flash-messages')
  declare flashMessages: FlashMessages;

  @service('router')
  declare router: RouterService;

  @readOnly('model.projectModel.project')
  project: any;

  @tracked
  error = false;

  @action
  async create({
    content,
    name,
    quickAccess
  }: {
    name: string | null;
    content: string;
    quickAccess: string | null;
  }) {
    return this.mutateResource({
      mutation: promptCreateQuery,
      successMessage: FLASH_MESSAGE_PROMPT_CREATE_SUCCESS,
      errorMessage: FLASH_MESSAGE_PROMPT_CREATE_ERROR,
      variables: {id: this.project.id, content, name, quickAccess}
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
      variables,
      refetchQueries: ['Project'],
      update: (
        cache: InMemoryCache,
        {
          data: {createProjectPrompt}
        }: {data: {createProjectPrompt: CreatePromptResponse}}
      ) => {
        cache.updateQuery(
          {
            query: projectPromptConfigQuery,
            variables: {projectId: this.project.id}
          },
          (data) => {
            return {
              viewer: {
                ...data.viewer,
                project: {
                  ...data.viewer.project,
                  prompts: data.viewer.project.prompts.concat([
                    createProjectPrompt.prompt
                  ])
                }
              }
            };
          }
        );
      }
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
