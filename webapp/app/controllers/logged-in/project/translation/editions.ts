import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {equal, and, readOnly} from '@ember/object/computed';
import Controller from '@ember/controller';
import translationUpdateQuery from 'accent-webapp/queries/update-translation';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import IntlService from 'ember-intl/services/intl';
import GlobalState from 'accent-webapp/services/global-state';
import FlashMessages from 'ember-cli-flash/services/flash-messages';

const FLASH_MESSAGE_UPDATE_SUCCESS =
  'pods.translation.edit.flash_messages.update_success';
const FLASH_MESSAGE_UPDATE_ERROR =
  'pods.translation.edit.flash_messages.update_error';

export default class TranslationEditionsController extends Controller {
  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('global-state')
  globalState: GlobalState;

  @service('intl')
  intl: IntlService;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @readOnly('globalState.permissions')
  permissions: any;

  @readOnly('model.revisionModel.project.revisions')
  revisions: any;

  @equal('model.translations', undefined)
  emptyEntries: boolean;

  @equal('query', '')
  emptyQuery: boolean;

  @and('emptyEntries', 'model.loading', 'emptyQuery')
  showSkeleton: boolean;

  @and('emptyEntries', 'model.loading')
  showLoading: boolean;

  @action
  async updateText(translation: any, text: string) {
    const response = await this.apolloMutate.mutate({
      mutation: translationUpdateQuery,
      variables: {
        translationId: translation.id,
        text,
      },
    });

    if (response.errors) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_UPDATE_ERROR));
    } else {
      this.flashMessages.success(this.intl.t(FLASH_MESSAGE_UPDATE_SUCCESS));
    }
  }
}
