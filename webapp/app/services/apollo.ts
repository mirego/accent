import Service, {inject as service} from '@ember/service';
import RouterService from '@ember/routing/router-service';

import {InMemoryCache} from '@apollo/client/cache';
import {ApolloClient} from '@apollo/client/core';
import {ApolloLink} from '@apollo/client/link/core';
import {BatchHttpLink} from '@apollo/client/link/batch-http';

import Session from 'accent-webapp/services/session';

const dataIdFromObject = (result: {id?: string; __typename: string}) => {
  if (result.id && result.__typename) return `${result.__typename}${result.id}`;

  return false;
};

const uri = '/graphql';
const cache = new InMemoryCache({dataIdFromObject});
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
          ...headers
        }
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
    link: ApolloLink.from([
      authLink(() => this.session),
      absintheBatchLink,
      link
    ]),
    cache
  });
}

declare module '@ember/service' {
  interface Registry {
    apollo: Apollo;
  }
}
