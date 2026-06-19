import Controller from '@ember/controller';
import {service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly, and, equal} from '@ember/object/computed';
import {tracked} from '@glimmer/tracking';
import RouterService from '@ember/routing/router-service';
import GlobalState from 'accent-webapp/services/global-state';

export default class LintController extends Controller {
  @service('global-state')
  declare globalState: GlobalState;

  @service('router')
  declare router: RouterService;

  get revisionId() {
    const route = this.router.currentRoute;
    const revisionRoute = route?.find(
      (info: any) => info.name === 'logged-in.project.revision'
    );

    return revisionRoute?.params?.revisionId ?? null;
  }

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

  @tracked
  checkFilter: string | null = null;

  queryParams = ['documentFilter', 'versionFilter', 'checkFilter', 'query'];

  @action
  changeQuery(query: string) {
    this.query = query;
  }

  @action
  changeCheckFilter(check: string | null) {
    this.checkFilter = this.checkFilter === check ? null : check;
  }
}
