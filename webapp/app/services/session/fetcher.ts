import Service from '@ember/service';
import config from 'accent-webapp/config/environment';

export default class SessionFetcher extends Service {
  fetch() {
    const credentials = localStorage.getItem(
      config.APP.LOCAL_STORAGE.SESSION_NAMESPACE
    );

    if (!credentials) return {};

    return JSON.parse(credentials);
  }
}

declare module '@ember/service' {
  interface Registry {
    'session/fetcher': SessionFetcher;
  }
}
