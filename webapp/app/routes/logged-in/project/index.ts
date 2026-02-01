import {service} from '@ember/service';
import Route from '@ember/routing/route';

import projectDashboardQuery from 'accent-webapp/queries/project-dashboard';
import RouteParams from 'accent-webapp/services/route-params';
import ApolloSubscription, {
  Subscription
} from 'accent-webapp/services/apollo-subscription';
import Transition from '@ember/routing/transition';

interface QueryParams extends Record<string, unknown> {
  document?: string | null;
  version?: string | null;
}

export default class ProjectIndexRoute extends Route {
  @service('apollo-subscription')
  declare apolloSubscription: ApolloSubscription;

  @service('route-params')
  declare routeParams: RouteParams;

  queryParams = {
    document: {refreshModel: true},
    version: {refreshModel: true}
  };

  subscription: Subscription;

  model(params: QueryParams, transition: Transition) {
    if (this.subscription)
      this.apolloSubscription.clearSubscription(this.subscription);

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
            documentId: params.document || null,
            versionId: params.version || null
          }
        }
      }
    );

    return this.subscription.currentResult();
  }

  deactivate() {
    this.apolloSubscription.clearSubscription(this.subscription);
  }
}
