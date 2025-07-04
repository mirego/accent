import {service} from '@ember/service';
import {readOnly} from '@ember/object/computed';
import Controller from '@ember/controller';
import JIPT from 'accent-webapp/services/jipt';

export default class LoginController extends Controller {
  @service('jipt')
  declare jipt: JIPT;

  @readOnly('model.loading')
  showLoading: boolean;

  constructor(...args: any) {
    super(...args);

    this.jipt.login();
  }
}
