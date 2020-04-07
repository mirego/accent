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

import config from 'accent-webapp/config/environment';
import Session from 'accent-webapp/services/session';

const uri = `${config.API.HOST}/graphql`;

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
            {name: 'ProjectIntegrationDiscord'},
            {name: 'ProjectIntegrationSlack'},
            {name: 'ProjectIntegrationGitHub'},
          ],
        },
      ],
    },
  },
});

const cache = new InMemoryCache({dataIdFromObject, fragmentMatcher});
const link = new BatchHttpLink({uri, batchInterval: 50, batchMax: 50});

const absintheBatchLink = new ApolloLink((operation, forward) => {
  // eslint-disable-next-line @typescript-eslint/ban-ts-ignore
  // @ts-ignore
  return forward(operation).map((response) => response.payload);
});

const authLink = (session: any) => {
  return new ApolloLink((operation, forward) => {
    const token = session.credentials.token;

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
    link: from([authLink(this.session), absintheBatchLink, link]),
    cache,
  });
}

declare module '@ember/service' {
  interface Registry {
    apollo: Apollo;
  }
}
