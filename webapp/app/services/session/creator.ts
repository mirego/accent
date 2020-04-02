import Service from '@ember/service';
import config from 'accent-webapp/config/environment';
import fetch from 'fetch';

const uri = `${config.API.HOST}/graphql`;

export default class SessionCreator extends Service {
  async createSession({token}: {token: string}) {
    const options = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
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
        `,
      }),
    };

    const response = await fetch(uri, options);
    const {data}: any = await response.json();
    return data;
  }
}

declare module '@ember/service' {
  interface Registry {
    'session/creator': SessionCreator;
  }
}
