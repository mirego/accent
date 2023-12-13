import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly} from '@ember/object/computed';
import {tracked} from '@glimmer/tracking';
import Controller from '@ember/controller';
import IntlService from 'ember-intl/services/intl';
import GlobalState from 'accent-webapp/services/global-state';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import RouterService from '@ember/routing/router-service';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import pushToAzureBlobStorage from 'accent-webapp/queries/push-to-azure-blob-storage';

const FLASH_MESSAGE_CREATE_SUCCESS =
  'pods.versions.new.flash_messages.create_success';
const FLASH_MESSAGE_CREATE_ERROR =
  'pods.versions.new.flash_messages.create_error';

export default class AzurePushController extends Controller {
  @tracked
  model: any;

  @service('intl')
  intl: IntlService;

  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('global-state')
  globalState: GlobalState;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @service('router')
  router: RouterService;

  @readOnly('model.projectModel.project')
  project: any;

  @tracked
  error = false;

  @action
  closeModal() {
    this.router.transitionTo(
      'logged-in.project.edit.service-integrations',
      this.project.id
    );
  }

  @action
  async pushStrings({
    targetVersion,
    specificVersion,
  }: {
    targetVersion: string;
    specificVersion: string | null;
  }) {
    const response = await this.apolloMutate.mutate({
      mutation: pushToAzureBlobStorage,
      variables: {
        targetVersion,
        specificVersion,
        projectId: this.project.id,
      },
    });

    if (response.errors) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_CREATE_ERROR));
    } else {
      this.flashMessages.success(this.intl.t(FLASH_MESSAGE_CREATE_SUCCESS));
    }

    this.router.transitionTo(
      'logged-in.project.edit.service-integrations',
      this.project.id
    );

    return response;
  }

  async delay(ms: number) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}
