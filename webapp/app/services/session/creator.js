import Service from '@ember/service';
import RSVP from 'rsvp';
import config from 'accent-webapp/config/environment';
import fetch from 'fetch';

export default Service.extend({
  createSession({token, provider}) {
    return new RSVP.Promise((resolve, reject) => {
      const uid = token;
      const options = {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({uid, provider})
      };

      fetch(config.API.AUTHENTICATION_PATH, options)
        .then(data => data.json().then(resolve))
        .catch((_jqXHR, _textStatus, error) => reject(error));
    });
  }
});
