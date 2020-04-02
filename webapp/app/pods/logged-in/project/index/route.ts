import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';

import projectDashboardQuery from 'accent-webapp/queries/project-dashboard';
import RouteParams from 'accent-webapp/services/route-params';
import ApolloSubscription, {
  Subscription,
} from 'accent-webapp/services/apollo-subscription';
import Transition from '@ember/routing/-private/transition';

export default class ProjectIndexRoute extends Route {
  @service('apollo-subscription')
  apolloSubscription: ApolloSubscription;

  @service('route-params')
  routeParams: RouteParams;

  subscription: Subscription;

  model(_params: object, transition: Transition) {
    const props = (data: any) => ({project: data.viewer.project});

    this.subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      projectDashboardQuery,
      {
        props,
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
