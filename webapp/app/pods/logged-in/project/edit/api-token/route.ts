import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';

import projectApiTokenQuery from 'accent-webapp/queries/project-api-token';
import RouteParams from 'accent-webapp/services/route-params';
import ApolloSubscription, {
  Subscription,
} from 'accent-webapp/services/apollo-subscription';
import Transition from '@ember/routing/-private/transition';

export default class APITokenRoute extends Route {
  @service('apollo-subscription')
  apolloSubscription: ApolloSubscription;

  @service('route-params')
  routeParams: RouteParams;

  subscription: Subscription;

  model(_params: any, transition: Transition) {
    this.subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      projectApiTokenQuery,
      {
        props: (data) => ({
          project: data.viewer.project,
        }),
        options: {
          fetchPolicy: 'cache-and-network',
          variables: {
            projectId: this.routeParams.fetch(transition, 'logged-in.project')
              .projectId,
          },
        },
      }
    );

    return this.subscription.currentResult();
  }

  deactivate() {
    this.apolloSubscription.clearSubscription(this.subscription);
  }
}
