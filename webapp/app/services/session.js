import {computed} from '@ember/object';
import {readOnly} from '@ember/object/computed';
import Service, {inject as service} from '@ember/service';

export default Service.extend({
  sessionFetcher: service('session/fetcher'),
  sessionPersister: service('session/persister'),
  sessionCreator: service('session/creator'),
  sessionDestroyer: service('session/destroyer'),
  jipt: service('jipt'),

  googleAuth: null,

  isAuthenticated: readOnly('credentials.user'),

  credentials: computed({
    get() {
      return this.sessionFetcher.fetch();
    },

    set(_, value) {
      this.sessionPersister.persist(value);
      return value;
    }
  }),

  login({token}) {
    return this.sessionCreator.createSession({token}).then(credentials => {
      if (!credentials || !credentials.viewer) return;

      this.set('credentials', {token, ...credentials.viewer});
      this.jipt.loggedIn();

      return credentials.viewer;
    });
  },

  logout() {
    this.sessionDestroyer.destroySession();
  }
});
