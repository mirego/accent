import {action} from '@ember/object';
import {service} from '@ember/service';
import Controller from '@ember/controller';
import Session from 'accent-webapp/services/session';

export default class NotFoundController extends Controller {
  @service('session')
  declare session: Session;

  @action
  logout() {
    this.session.logout();

    window.location.href = '/';
  }
}
