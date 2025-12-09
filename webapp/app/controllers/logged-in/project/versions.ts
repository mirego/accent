import {service} from '@ember/service';
import {action} from '@ember/object';
import {equal, readOnly, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import versionDeleteQuery from 'accent-webapp/queries/delete-version';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';

const FLASH_MESSAGE_DELETE_SUCCESS =
  'pods.versions.index.flash_messages.delete_success';
const FLASH_MESSAGE_DELETE_ERROR =
  'pods.versions.index.flash_messages.delete_error';

export default class VersionsController extends Controller {
  @service('intl')
  declare intl: IntlService;

  @service('flash-messages')
  declare flashMessages: FlashMessages;

  @service('apollo-mutate')
  declare apolloMutate: ApolloMutate;

  @service('global-state')
  declare globalState: GlobalState;

  @tracked
  page = 1;

  @equal('model.versions', undefined)
  emptyEntries: boolean;

  @readOnly('globalState.permissions')
  permissions: any;

  @and('emptyEntries', 'model.loading')
  showSkeleton: boolean;

  @action
  async deleteVersion(versionEntity: any) {
    const response = await this.apolloMutate.mutate({
      mutation: versionDeleteQuery,
      variables: {
        versionId: versionEntity.id
      }
    });

    if (response.errors) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_DELETE_ERROR));
    } else {
      this.flashMessages.success(this.intl.t(FLASH_MESSAGE_DELETE_SUCCESS));
      this.send('onRefresh');
    }
  }

  @action
  selectPage(page: number) {
    window.scroll(0, 0);

    this.page = page;
  }
}
