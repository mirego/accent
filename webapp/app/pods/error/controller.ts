import {inject as service} from '@ember/service';
import Controller from '@ember/controller';
import IntlService from 'ember-intl/services/intl';
import Session from 'accent-webapp/services/session';
import {action} from '@ember/object';

const UNAUTHORIZED = 'unauthorized';
const INTERNAL_ERROR = 'internal_error';

export default class ErrorController extends Controller {
  @service('intl')
  intl: IntlService;

  @service('session')
  session: Session;

  title = this.translationAttribute('title');
  status = this.translationAttribute('status');
  text = this.translationAttribute('text');

  get firstError() {
    return this.model.errors[0];
  }

  get isUnauthorized() {
    return this.firstError.status === '401';
  }

  get translationPrefix() {
    return this.isUnauthorized ? UNAUTHORIZED : INTERNAL_ERROR;
  }

  @action
  logout() {
    this.session.logout();

    window.location.href = '/';
  }

  private translationAttribute(attribute: string) {
    return this.intl.t(`pods.error.${this.translationPrefix}.${attribute}`);
  }
}
