import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {equal, and, readOnly} from '@ember/object/computed';
import Controller from '@ember/controller';
import JIPT from 'accent-webapp/services/jipt';
import GlobalState from 'accent-webapp/services/global-state';
import Session from 'accent-webapp/services/session';

export default class ProjectsController extends Controller {
  @service('jipt')
  jipt: JIPT;

  @service('global-state')
  globalState: GlobalState;

  @service('session')
  session: Session;

  queryParams = ['query', 'page'];

  query = '';
  page = 1;

  @readOnly('model.permissions')
  permissions: any;

  @equal('model.projects.entries', undefined)
  emptyEntries: boolean;

  @and('emptyEntries', 'model.loading')
  showLoading: boolean;

  constructor() {
    super(...arguments);

    this.jipt.redirectIfEmbedded();
  }

  @action
  changeQuery(query: string) {
    this.set('query', query);
  }

  @action
  selectPage(page: string) {
    window.scrollTo(0, 0);
    this.set('page', page);
  }
}
