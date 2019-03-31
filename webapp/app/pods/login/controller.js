import {inject as service} from '@ember/service';
import {computed} from '@ember/object';
import Controller from '@ember/controller';
import config from 'accent-webapp/config/environment';

export default Controller.extend({
  jipt: service('jipt'),
  session: service('session'),

  username: '',

  init() {
    this.jipt.login();
  },

  googleLoginEnabled: computed(() => config.GOOGLE_LOGIN_ENABLED),
  dummyLoginEnabled: computed(() => config.DUMMY_LOGIN_ENABLED),

  actions: {
    dummyLogin(token) {
      this._login({token, provider: 'dummy'});
    }
  },

  _login({token, provider}) {
    this.session.login({token, provider}).then(data => {
      if (data && data.token) this.transitionToRoute('logged-in.projects');
    });
  }
});
