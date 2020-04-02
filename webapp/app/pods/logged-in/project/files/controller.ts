import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {equal, readOnly, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import documentDeleteQuery from 'accent-webapp/queries/delete-document';
import documentUpdateQuery from 'accent-webapp/queries/update-document';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';

const FLASH_MESSAGE_DELETE_SUCCESS =
  'pods.document.index.flash_messages.delete_success';
const FLASH_MESSAGE_DELETE_ERROR =
  'pods.document.index.flash_messages.delete_error';
const FLASH_MESSAGE_UPDATE_SUCCESS =
  'pods.document.index.flash_messages.update_success';
const FLASH_MESSAGE_UPDATE_ERROR =
  'pods.document.index.flash_messages.update_error';

export default class FilesController extends Controller {
  @service('intl')
  intl: IntlService;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('global-state')
  globalState: GlobalState;

  @tracked
  page = 1;

  @equal('model.documents', undefined)
  emptyEntries: boolean;

  @readOnly('globalState.permissions')
  permissions: any;

  @and('emptyEntries', 'model.loading')
  showSkeleton: boolean;

  @action
  async deleteDocument(documentEntity: any) {
    try {
      await this.apolloMutate.mutate({
        mutation: documentDeleteQuery,
        variables: {
          documentId: documentEntity.id,
        },
      });

      this.flashMessages.success(this.intl.t(FLASH_MESSAGE_DELETE_SUCCESS));
      this.send('onRefresh');
    } catch (error) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_DELETE_ERROR));
    }
  }

  @action
  async updateDocument(documentEntity: any, path: string) {
    try {
      await this.apolloMutate.mutate({
        mutation: documentUpdateQuery,
        variables: {
          documentId: documentEntity.id,
          path,
        },
      });

      this.flashMessages.success(this.intl.t(FLASH_MESSAGE_UPDATE_SUCCESS));
      this.send('onRefresh');
    } catch (error) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_UPDATE_ERROR));
    }
  }

  @action
  selectPage(page: number) {
    window.scroll(0, 0);

    this.page = page;
  }
}
