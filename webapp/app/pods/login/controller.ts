import {inject as service} from '@ember/service';
import Controller from '@ember/controller';
import JIPT from 'accent-webapp/services/jipt';

export default class LoginController extends Controller {
  @service('jipt')
  jipt: JIPT;

  constructor(...args: any) {
    super(...args);

    this.jipt.login();
  }
}
