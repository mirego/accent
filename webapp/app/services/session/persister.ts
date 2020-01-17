import Service from '@ember/service';
import config from 'accent-webapp/config/environment';

export default class SessionPersister extends Service {
  persist(session: object) {
    localStorage.setItem(
      config.APP.LOCAL_STORAGE.SESSION_NAMESPACE,
      JSON.stringify(session)
    );
  }
}

declare module '@ember/service' {
  interface Registry {
    'session/persister': SessionPersister;
  }
}
