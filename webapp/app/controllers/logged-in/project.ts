import {service} from '@ember/service';
import {readOnly, not, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import Session from 'accent-webapp/services/session';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';

export default class ProjectController extends Controller {
  @service('session')
  declare session: Session;

  @service('global-state')
  declare globalState: GlobalState;

  @tracked
  defaultColor = '#25ba7c';

  @readOnly('model.project')
  project: any;

  @readOnly('globalState.mainColor')
  mainColor: string;

  @readOnly('project.revisions')
  revisions: any;

  @readOnly('globalState.permissions')
  permissions: any;

  @not('project')
  noProject: boolean;

  @not('model.loading')
  notLoading: boolean;

  @and('noProject', 'notLoading')
  showError: boolean;

  get colors() {
    return `
    --color-primary: ${this.mainColor || this.defaultColor};
    `;
  }

  get darkColors() {
    return '';
  }
}
