import Service from '@ember/service';
import fetch from 'fetch';

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

    const response = await fetch('/graphql', options);
    const {data}: any = await response.json();
    return data;
  }
}

declare module '@ember/service' {
  interface Registry {
    'session/creator': SessionCreator;
  }
}
