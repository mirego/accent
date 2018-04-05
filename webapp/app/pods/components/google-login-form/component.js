import {inject as service} from '@ember/service';
import Component from '@ember/component';

// Attributes:
// onGoogleLogin: Function
export default Component.extend({
  session: service('session'),

  didInsertElement() {
    const loginButton = document.querySelector('.googleLoginButton');

    if (loginButton) {
      this.session.googleAuth.attachClickHandler(
        loginButton,
        {},
        googleUser => this._authSuccess(googleUser),
        error => window.console.error(error)
      );
    }
  },

  _authSuccess(googleUser) {
    this.onGoogleLogin(googleUser);
  }
});
