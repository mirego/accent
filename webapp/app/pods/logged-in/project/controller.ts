/* eslint-disable no-magic-numbers */
import {inject as service} from '@ember/service';
import {readOnly, not, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import Color from 'color';
import Session from 'accent-webapp/services/session';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';

export default class ProjectController extends Controller {
  @service('session')
  session: Session;

  @service('global-state')
  globalState: GlobalState;

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
    const color = Color(this.mainColor || this.defaultColor);

    return `
    --accent-hue: ${color.hue()};

    --color-primary: ${color.string()};
    --color-primary-hue: ${color.hue()};
    --color-primary-saturation: ${color.saturationv()}%;
    --color-primary-darken-10: ${color.darken(0.1).string()};
    --color-primary-opacity-10: ${color.fade(0.9).string()};
    --color-primary-opacity-50: ${color.fade(0.5).string()};
    --color-primary-opacity-70: ${color.fade(0.3).string()};
    --color-black: ${color.darken(0.7).desaturate(0.3).string()};
    `;
  }

  get darkColors() {
    const color = Color(this.mainColor || this.defaultColor);

    return `
    --color-black: ${color.desaturate(0.9).lighten(0.6).string()};
    `;
  }
}
