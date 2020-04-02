import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';

import translationUpdateQuery from 'accent-webapp/queries/update-translation';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import IntlService from 'ember-intl/services/intl';
import GlobalState from 'accent-webapp/services/global-state';

const FLASH_MESSAGE_UPDATE_SUCCESS =
  'pods.translation.edit.flash_messages.update_success';
const FLASH_MESSAGE_UPDATE_ERROR =
  'pods.translation.edit.flash_messages.update_error';

export default class RelatedTranslations extends Controller {
  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @service('intl')
  intl: IntlService;

  @service('global-state')
  globalState: GlobalState;

  @readOnly('globalState.permissions')
  permissions: any;

  @equal('model.relatedTranslations', undefined)
  emptyEntries: boolean;

  @and('emptyEntries', 'model.loading')
  showSkeleton: boolean;

  @action
  async updateTranslation(translation: any, text: string) {
    try {
      await this.apolloMutate.mutate({
        mutation: translationUpdateQuery,
        variables: {
          translationId: translation.id,
          text,
        },
      });

      this.flashMessages.success(this.intl.t(FLASH_MESSAGE_UPDATE_SUCCESS));
    } catch (error) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_UPDATE_ERROR));
    }
  }
}
