import {service} from '@ember/service';
import {action} from '@ember/object';
import {equal, readOnly, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';

export default class VersionsController extends Controller {
  @service('intl')
  declare intl: IntlService;

  @service('flash-messages')
  declare flashMessages: FlashMessages;

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
  selectPage(page: number) {
    window.scroll(0, 0);

    this.page = page;
  }
}
