import {readOnly} from '@ember/object/computed';
import Service, {inject as service} from '@ember/service';
import SessionFetcher from 'accent-webapp/services/session/fetcher';
import SessionPersister from 'accent-webapp/services/session/persister';
import SessionCreator from 'accent-webapp/services/session/creator';
import SessionDestroyer from 'accent-webapp/services/session/destroyer';
import JIPT from 'accent-webapp/services/jipt';

interface LoginOptions {
  token: string;
}

export default class Session extends Service {
  @service('session/fetcher')
  sessionFetcher: SessionFetcher;

  @service('session/persister')
  sessionPersister: SessionPersister;

  @service('session/creator')
  sessionCreator: SessionCreator;

  @service('session/destroyer')
  sessionDestroyer: SessionDestroyer;

  @service('jipt')
  jipt: JIPT;

  googleAuth = null;

  @readOnly('credentials.user')
  isAuthenticated: boolean;

  get credentials() {
    return this.sessionFetcher.fetch();
  }

  async login({token}: LoginOptions) {
    const credentials = await this.sessionCreator.createSession({token});

    if (!credentials || !credentials.viewer) return;

    this.sessionPersister.persist({token, ...credentials.viewer});

    this.jipt.loggedIn();

    return credentials.viewer;
  }

  logout() {
    this.sessionDestroyer.destroySession();
  }
}

declare module '@ember/service' {
  interface Registry {
    session: Session;
  }
}
