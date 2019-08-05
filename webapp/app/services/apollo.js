import Service, {inject as service} from '@ember/service';
import ApolloClient, {IntrospectionFragmentMatcher, InMemoryCache} from 'apollo-boost';
import config from 'accent-webapp/config/environment';

const uri = `${config.API.HOST}/graphql`;

const dataIdFromObject = result => {
  if (result.id && result.__typename) {
    return `${result.__typename}${result.id}`;
  }

  return null;
};

debugger;
const fragmentMatcher = new IntrospectionFragmentMatcher({
  introspectionQueryResultData: {
    __schema: {
      types: [
        {
          kind: 'INTERFACE',
          name: 'ProjectIntegration',
          possibleTypes: ['ProjectIntegrationSlack', 'ProjectIntegrationGitHub']
        }
      ]
    }
  }
});

const cache = new InMemoryCache({dataIdFromObject, fragmentMatcher});

// Simple one-to-one interface to the apollo client query function.
export default Service.extend({
  router: service('router'),
  session: service('session'),

  init() {
    this._super(...arguments);

    const client = new ApolloClient({
      uri,
      cache,
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
