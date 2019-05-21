import Service from '@ember/service';
import RSVP from 'rsvp';
import config from 'accent-webapp/config/environment';
import fetch from 'fetch';

const uri = `${config.API.HOST}/graphql`;

export default Service.extend({
  createSession({token}) {
    return new RSVP.Promise((resolve, reject) => {
      const options = {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`
        },
        body: JSON.stringify({
          query: `
        query Viewer {
          viewer {
            user {
              id
              email
              pictureUrl
              fullname
            }
          }
        }
        `
        })
      };

      fetch(uri, options)
        .then(data => data.json().then(({data}) => resolve(data)))
        .catch((_jqXHR, _textStatus, error) => reject(error));
    });
  }
});
