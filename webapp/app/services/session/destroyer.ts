import Service from '@ember/service';
import config from 'accent-webapp/config/environment';

export default class SessionDestroyer extends Service {
  destroySession() {
    const session = config.APP.LOCAL_STORAGE.SESSION_NAMESPACE;
    localStorage.removeItem(session);
  }
}

declare module '@ember/service' {
  interface Registry {
    'session/destroyer': SessionDestroyer;
  }
}
