import {inject as service} from '@ember/service';
import Controller from '@ember/controller';
import FlashMessages from 'ember-cli-flash/services/flash-messages';

export default class LoggedIn extends Controller {
  @service('flash-messages')
  flashMessages: FlashMessages;
}
