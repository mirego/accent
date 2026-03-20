import {service} from '@ember/service';
import {action} from '@ember/object';
import Controller from '@ember/controller';
import {readOnly} from '@ember/object/computed';
import RouterService from '@ember/routing/router-service';
import {tracked} from '@glimmer/tracking';
import GlobalState from 'accent-webapp/services/global-state';

export default class JIPTController extends Controller {
  @service('router')
  declare router: RouterService;

  @service('global-state')
  declare globalState: GlobalState;

  queryParams = ['revisionId'];

  @tracked
  defaultColor = '#25ba7c';

  @tracked
  revisionId: string | null = null;

  @readOnly('model.project.revision')
  revision: any;

  @readOnly('globalState.mainColor')
  mainColor: string;

  @readOnly('model.project.revisions')
  revisions: any;

  constructor(...args: any[]) {
    super(...args);

    window.addEventListener(
      'message',
      (payload) => {
        if (payload.data.jipt && payload.data.selectId) {
          this.router.transitionTo(
            'logged-in.jipt.translation',
            payload.data.selectId,
          );
        }
        if (payload.data.jipt && payload.data.selectIds) {
          this.router.transitionTo('logged-in.jipt.index', {
            queryParams: {translationIds: payload.data.selectIds},
          });
        }
      },
      false,
    );
  }

  get colors() {
    return `
    --color-primary: ${this.mainColor || this.defaultColor};
    `;
  }

  @action
  selectRevision(revisionId: string) {
    this.revisionId = revisionId;
  }
}
