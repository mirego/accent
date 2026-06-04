import {service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import {tracked} from '@glimmer/tracking';
import IntlService from 'ember-intl/services/intl';
import GlobalState from 'accent-webapp/services/global-state';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';

import createLintEntryQuery from 'accent-webapp/queries/create-project-lint-entry';
import updateLintEntryQuery from 'accent-webapp/queries/update-project-lint-entry';
import deleteLintEntryQuery from 'accent-webapp/queries/delete-project-lint-entry';

const FLASH_MESSAGE_PREFIX = 'pods.project.edit.lint_entries.flash_messages.';

export default class LintEntriesController extends Controller {
  @service('intl')
  declare intl: IntlService;

  @service('global-state')
  declare globalState: GlobalState;

  @service('apollo-mutate')
  declare apolloMutate: ApolloMutate;

  @service('flash-messages')
  declare flashMessages: FlashMessages;

  queryParams = ['page'];

  @tracked
  page = 1;

  @readOnly('model.project')
  project: any;

  @readOnly('model.lintEntries')
  lintEntries: any;

  @readOnly('globalState.permissions')
  permissions: any;

  @equal('model.project.name', undefined)
  emptyData: boolean;

  @and('emptyData', 'model.loading')
  showLoading: boolean;

  @action
  selectPage(page: number) {
    window.scroll(0, 0);

    this.page = page;
  }

  @action
  async createLintEntry(attrs: object) {
    return this.mutateResource({
      mutation: createLintEntryQuery,
      successMessage: `${FLASH_MESSAGE_PREFIX}create_success`,
      errorMessage: `${FLASH_MESSAGE_PREFIX}create_error`,
      variables: {...attrs, projectId: this.project.id}
    });
  }

  @action
  async updateLintEntry(attrs: {id: string}) {
    return this.mutateResource({
      mutation: updateLintEntryQuery,
      successMessage: `${FLASH_MESSAGE_PREFIX}update_success`,
      errorMessage: `${FLASH_MESSAGE_PREFIX}update_error`,
      variables: attrs
    });
  }

  @action
  async deleteLintEntry(id: string) {
    return this.mutateResource({
      mutation: deleteLintEntryQuery,
      successMessage: `${FLASH_MESSAGE_PREFIX}remove_success`,
      errorMessage: `${FLASH_MESSAGE_PREFIX}remove_error`,
      variables: {id}
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
      refetchQueries: ['ProjectLintEntries']
    });

    if (response.errors) {
      this.flashMessages.error(this.intl.t(errorMessage));
    } else {
      this.flashMessages.success(this.intl.t(successMessage));
    }

    return response;
  }
}
