import {tracked} from '@glimmer/tracking';
import Service, {service} from '@ember/service';
import SessionCreator from 'accent-webapp/services/session/creator';
import JIPT from 'accent-webapp/services/jipt';

interface User {
  id: string;
  email: string;
  pictureUrl: string;
  fullname: string;
}

interface Credentials {
  user?: User;
}

export default class Session extends Service {
  @service('session/creator')
  declare sessionCreator: SessionCreator;

  @service('jipt')
  declare jipt: JIPT;

  @tracked
  credentials: Credentials = {};

  get isAuthenticated(): boolean {
    return Boolean(this.credentials.user);
  }

  async login() {
    const credentials = await this.sessionCreator.createSession();

    if (!credentials || !credentials.viewer) return;

    this.credentials = credentials.viewer;

    this.jipt.loggedIn();

    return credentials.viewer;
  }

  logout() {
    window.location.href = '/auth/logout';
  }
}

declare module '@ember/service' {
  interface Registry {
    session: Session;
  }
}
