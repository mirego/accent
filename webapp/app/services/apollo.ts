import Service, {inject as service} from '@ember/service';
import RouterService from '@ember/routing/router-service';
import {ApolloClient} from 'apollo-client';
import {BatchHttpLink} from 'apollo-link-batch-http';
import {
  IntrospectionFragmentMatcher,
  InMemoryCache,
  from,
  ApolloLink,
} from 'apollo-boost';

import Session from 'accent-webapp/services/session';

const dataIdFromObject = (result: {id?: string; __typename: string}) => {
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
            {name: 'ProjectIntegrationAzureStorageContainer'},
            {name: 'ProjectIntegrationDiscord'},
            {name: 'ProjectIntegrationSlack'},
          ],
        },
      ],
    },
  },
});

const uri = '/graphql';
const cache = new InMemoryCache({dataIdFromObject, fragmentMatcher});
const link = new BatchHttpLink({uri, batchInterval: 1, batchMax: 1});

const absintheBatchLink = new ApolloLink((operation, forward) => {
  return forward(operation).map((response: any) => response.payload);
});

const authLink = (getSession: any) => {
  return new ApolloLink((operation, forward) => {
    const token = getSession().credentials.token;

    if (token) {
      operation.setContext(({headers = {}}: any) => ({
        headers: {
          ...headers,
          authorization: `Bearer ${token}`,
        },
      }));
    }

    return forward(operation);
  });
};

export default class Apollo extends Service {
  @service('router')
  router: RouterService;

  @service('session')
  session: Session;

  client = new ApolloClient({
    link: from([authLink(() => this.session), absintheBatchLink, link]),
    cache,
  });
}

declare module '@ember/service' {
  interface Registry {
    apollo: Apollo;
  }
}
