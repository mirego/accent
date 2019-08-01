import {inject as service} from '@ember/service';
import Controller from '@ember/controller';

export default Controller.extend({
  jipt: service('jipt'),

  init() {
    this._super(...arguments);
    this.jipt.login();
  }
});
