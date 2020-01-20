import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';

export default class ActivitiesController extends Controller {
  @service('intl')
  intl: IntlService;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('global-state')
  globalState: GlobalState;

  queryParams = ['batchFilter', 'actionFilter', 'userFilter', 'page'];

  @tracked
  batchFilter: boolean | null = null;

  @tracked
  actionFilter = null;

  @tracked
  userFilter = null;

  @tracked
  page = 1;

  @readOnly('globalState.permissions')
  permissions: any;

  @equal('model.activities', undefined)
  emptyEntries: boolean;

  @and('emptyEntries', 'model.loading')
  showSkeleton: boolean;

  @action
  batchFilterChange(checked: boolean) {
    this.batchFilter = checked ? true : null;
    this.page = 1;
  }

  @action
  actionFilterChange(actionFilter: any) {
    this.actionFilter = actionFilter;
    this.page = 1;
  }

  @action
  userFilterChange(user: any) {
    this.userFilter = user;
    this.page = 1;
  }

  @action
  selectPage(page: number) {
    window.scroll(0, 0);

    this.page = page;
  }
}
