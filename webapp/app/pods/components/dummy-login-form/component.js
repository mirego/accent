import {inject as service} from '@ember/service';
import Component from '@ember/component';

// Attributes:
// onDummyLogin: Function
export default Component.extend({
  session: service('session'),

  email: '',

  actions: {
    submit() {
      this.onDummyLogin(this.email);
    }
  }
});
