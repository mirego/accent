import Controller from '@ember/controller';
import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly, and, equal} from '@ember/object/computed';
import {tracked} from '@glimmer/tracking';
import GlobalState from 'accent-webapp/services/global-state';

export default class LintController extends Controller {
  @service('global-state')
  globalState: GlobalState;

  @readOnly('globalState.permissions')
  permissions: any;

  @equal('model.lintTranslations', undefined)
  emptyEntries: boolean;

  @and('emptyEntries', 'model.loading')
  showLoading: boolean;

  @and('emptyEntries', 'model.loading')
  showSkeleton: boolean;

  @tracked
  documentFilter = null;

  @tracked
  versionFilter = null;

  @tracked
  query = '';

  queryParams = ['documentFilter', 'versionFilter', 'ruleFilter', 'query'];

  @action
  changeQuery(query: string) {
    this.query = query;
  }
}
