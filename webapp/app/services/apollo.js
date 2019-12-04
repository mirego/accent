import Service, {inject as service} from '@ember/service';
import {ApolloClient} from 'apollo-client';
import {BatchHttpLink} from 'apollo-link-batch-http';
import {
  IntrospectionFragmentMatcher,
  InMemoryCache,
  from,
  ApolloLink
} from 'apollo-boost';

import config from 'accent-webapp/config/environment';

const uri = `${config.API.HOST}/graphql`;

const dataIdFromObject = result => {
  if (result.id && result.__typename) return `${result.__typename}${result.id}`;

  return null;
};

const fragmentMatcher = new IntrospectionFragmentMatcher({
  introspectionQueryResultData: {
    __schema: {
      types: [
        {
          kind: 'INTERFACE',
          name: 'ProjectIntegration',
          possibleTypes: [
            'ProjectIntegrationDiscord',
            'ProjectIntegrationSlack',
            'ProjectIntegrationGitHub'
          ]
        }
      ]
    }
  }
});

const cache = new InMemoryCache({dataIdFromObject, fragmentMatcher});
const link = new BatchHttpLink({uri, batchInterval: 50, batchMax: 50});
const absintheBatchLink = new ApolloLink((operation, forward) => {
  return forward(operation).map(response => response.payload);
});
const authLink = (session) => {
  return new ApolloLink((operation, forward) => {
    const token = session.credentials.token;

    if (token) {
      operation.setContext(({headers = {}}) => ({
        headers: {
          ...headers,
          authorization: `Bearer ${token}`
        }
      }));
    }

    return forward(operation);
  });
};

export default Service.extend({
  router: service('router'),
  session: service('session'),

  init() {
    this._super(...arguments);

    const client = new ApolloClient({
      uri,
      link: from([
        authLink(this.session),
        absintheBatchLink,
        link
      ]),
      cache
    });

    this.set('client', client);
  }
});
