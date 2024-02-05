/* eslint-disable no-magic-numbers */
import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import Controller from '@ember/controller';
import {readOnly} from '@ember/object/computed';
import Color from 'color';
import RouterService from '@ember/routing/router-service';
import {tracked} from '@glimmer/tracking';

export default class JIPTController extends Controller {
  @service('router')
  router: RouterService;

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

  constructor(...args: any) {
    super(...args);

    window.addEventListener(
      'message',
      (payload) => {
        if (payload.data.jipt && payload.data.selectId) {
          this.router.transitionTo(
            'logged-in.jipt.translation',
            payload.data.selectId
          );
        }
        if (payload.data.jipt && payload.data.selectIds) {
          this.router.transitionTo('logged-in.jipt.index', {
            queryParams: {translationIds: payload.data.selectIds},
          });
        }
      },
      false
    );
  }

  get colors() {
    const color = Color(this.mainColor || this.defaultColor);

    return `
    --color-primary: ${color.string()};
    --color-primary-darken-10: ${color.darken(0.1).string()};
    --color-primary-opacity-10: ${color.fade(0.9).string()};
    --color-primary-opacity-70: ${color.fade(0.3).string()};
    --color-black: ${color.darken(0.7).desaturate(0.3).string()};
    `;
  }

  @action
  selectRevision(revisionId: string) {
    this.revisionId = revisionId;
  }
}
