import {inject as service} from '@ember/service';
import Component from '@ember/component';

// Attributes:
// session: Service <session>
export default Component.extend({
  tagName: 'header',
  session: service('session'),

  actions: {
    logout() {
      this.session.logout();
      window.location = '/';
    }
  }
});
