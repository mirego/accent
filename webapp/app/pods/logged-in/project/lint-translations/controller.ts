import Controller from '@ember/controller';
import {inject as service} from '@ember/service';
import {readOnly, and, equal} from '@ember/object/computed';
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
}
