import Component from '@ember/component';
import config from 'accent-webapp/config/environment';

export default Component.extend({
  loginEnabled: false,

  didInsertElement() {
    const loginButton = this.element.querySelector('.googleLoginButton');

    this._loadGoogleScript().then(() => {
      if (!window.gapi) return;
      this.set('loginEnabled', true);

      window.gapi.load('auth2', () => {
        const google = window.gapi.auth2.init({
          client_id: config.GOOGLE_API.CLIENT_ID, // eslint-disable-line camelcase
          ux_mode: 'redirect', // eslint-disable-line camelcase
          cookiepolicy: 'single_host_origin'
        });

        google.attachClickHandler(loginButton);
      });
    });
  },

  _loadGoogleScript() {
    return new Promise((resolve, reject) => {
      let script = document.createElement('script');
      const prior = this.element;

      script.async = true;
      script.defer = true;

      const onloadHander = (_, isAbort) => {
        if (
          isAbort ||
          !script.readyState ||
          /loaded|complete/.test(script.readyState)
        ) {
          script.onload = null;
          script.onreadystatechange = null;
          script = undefined;

          if (isAbort) {
            reject();
          } else {
            resolve();
          }
        }
      };

      script.onload = onloadHander;
      script.onreadystatechange = onloadHander;

      script.src = 'https://apis.google.com/js/api:client.js';
      prior.parentNode.insertBefore(script, prior);
    });
  }
});
