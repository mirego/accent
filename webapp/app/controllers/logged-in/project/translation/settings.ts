import {service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly} from '@ember/object/computed';
import Controller from '@ember/controller';
import translationSettingsUpdateQuery from 'accent-webapp/queries/update-translation-settings';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import GlobalState from 'accent-webapp/services/global-state';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import {tracked} from '@glimmer/tracking';

const FLASH_MESSAGE_SETTINGS_SUCCESS =
  'pods.translation.settings.flash_messages.success';
const FLASH_MESSAGE_SETTINGS_ERROR =
  'pods.translation.settings.flash_messages.error';

export default class SettingsController extends Controller {
  @tracked
  model: any;

  @service('apollo-mutate')
  declare apolloMutate: ApolloMutate;

  @service('global-state')
  declare globalState: GlobalState;

  @service('intl')
  declare intl: IntlService;

  @service('flash-messages')
  declare flashMessages: FlashMessages;

  @readOnly('globalState.permissions')
  permissions: any;

  @action
  async updateSettings(settingsAttributes: {
    plural: boolean;
    locked: boolean;
    placeholders: string[];
    fileIndex: number | null;
    fileComment: string | null;
    valueType: string;
    sourceTranslationId: string | null;
  }) {
    const translation = this.model.translation;

    const response = await this.apolloMutate.mutate({
      mutation: translationSettingsUpdateQuery,
      refetchQueries: ['Translation'],
      variables: {
        translationId: translation.id,
        ...settingsAttributes
      }
    });

    if (response.errors) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_SETTINGS_ERROR));
    } else {
      this.flashMessages.success(this.intl.t(FLASH_MESSAGE_SETTINGS_SUCCESS));
    }
  }
}
