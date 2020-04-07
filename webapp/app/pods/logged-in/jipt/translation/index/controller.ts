import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly} from '@ember/object/computed';
import Controller from '@ember/controller';
import translationCorrectQuery from 'accent-webapp/queries/correct-translation';
import translationUncorrectQuery from 'accent-webapp/queries/uncorrect-translation';
import translationUpdateQuery from 'accent-webapp/queries/update-translation';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import GlobalState from 'accent-webapp/services/global-state';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import JIPT from 'accent-webapp/services/jipt';

const FLASH_MESSAGE_CORRECT_SUCCESS =
  'pods.translation.edit.flash_messages.correct_success';
const FLASH_MESSAGE_CORRECT_ERROR =
  'pods.translation.edit.flash_messages.correct_error';

const FLASH_MESSAGE_UNCORRECT_SUCCESS =
  'pods.translation.edit.flash_messages.uncorrect_success';
const FLASH_MESSAGE_UNCORRECT_ERROR =
  'pods.translation.edit.flash_messages.uncorrect_error';

const FLASH_MESSAGE_UPDATE_SUCCESS =
  'pods.translation.edit.flash_messages.update_success';
const FLASH_MESSAGE_UPDATE_ERROR =
  'pods.translation.edit.flash_messages.update_error';

export default class IndexController extends Controller {
  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('global-state')
  globalState: GlobalState;

  @service('intl')
  intl: IntlService;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @service('jipt')
  jipt: JIPT;

  @readOnly('globalState.permissions')
  permissions: any;

  @action
  changeText(text: string) {
    this.jipt.changeText(this.model.translation.id, text);
  }

  @action
  async correctConflict(text: string) {
    const conflict = this.model.translation;

    try {
      await this.apolloMutate.mutate({
        mutation: translationCorrectQuery,
        variables: {
          translationId: conflict.id,
          text,
        },
      });

      this.jipt.updateTranslation(
        this.model.translation.id,
        this.model.translation
      );

      this.flashMessages.success(this.intl.t(FLASH_MESSAGE_CORRECT_SUCCESS));
    } catch (error) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_CORRECT_ERROR));
    }
  }

  @action
  async uncorrectConflict() {
    const conflict = this.model.translation;

    try {
      await this.apolloMutate.mutate({
        mutation: translationUncorrectQuery,
        variables: {
          translationId: conflict.id,
        },
      });

      this.jipt.updateTranslation(
        this.model.translation.id,
        this.model.translation
      );

      this.flashMessages.success(this.intl.t(FLASH_MESSAGE_UNCORRECT_SUCCESS));
    } catch (error) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_UNCORRECT_ERROR));
    }
  }

  @action
  async updateText(text: string) {
    const translation = this.model.translation;

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
