import {computed} from '@ember/object';
import {readOnly} from '@ember/object/computed';
import Service, {inject as service} from '@ember/service';

export default Service.extend({
  sessionFetcher: service('session/fetcher'),
  sessionPersister: service('session/persister'),
  sessionCreator: service('session/creator'),
  sessionDestroyer: service('session/destroyer'),

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

  login(...args) {
    return this.sessionCreator.createSession(...args).then(credentials => this.set('credentials', credentials));
  },

  logout() {
    this.sessionDestroyer.destroySession();
    if (this.googleAuth) this.googleAuth.disconnect();
  }
});
