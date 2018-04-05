import Service, {inject as service} from '@ember/service';
import apollo from 'npm:apollo-boost';
import config from 'accent-webapp/config/environment';

const ApolloClient = apollo.default;
const uri = `${config.API.HOST}/graphql`;

// Simple one-to-one interface to the apollo client query function.
export default Service.extend({
  router: service('router'),
  session: service('session'),

  init() {
    const client = new ApolloClient({
      uri,
      request: operation => {
        const token = this.session.credentials.token;
        if (!token) return this.router.transitionTo('login');

        operation.setContext({
          headers: {
            authorization: `Bearer ${token}`
          }
        });
      }
    });

    this.set('client', client);
  }
});
