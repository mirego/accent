import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';

import projectVersionsQuery from 'accent-webapp/queries/project-versions';
import ApolloSubscription, {
  Subscription,
} from 'accent-webapp/services/apollo-subscription';
import RouteParams from 'accent-webapp/services/route-params';
import Transition from '@ember/routing/-private/transition';

export default class VersionsRoute extends Route {
  @service('apollo-subscription')
  apolloSubscription: ApolloSubscription;

  @service('route-params')
  routeParams: RouteParams;

  queryParams = {
    page: {
      refreshModel: true,
    },
  };

  subscription: Subscription;

  model({page}: {page: string}, transition: Transition) {
    const pageNumber = page ? parseInt(page, 10) : null;

    this.subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      projectVersionsQuery,
      {
        props: (data) => ({
          project: data.viewer.project,
          versions: data.viewer.project.versions,
          documents: data.viewer.project.documents,
        }),
        options: {
          fetchPolicy: 'cache-and-network',
          variables: {
            projectId: this.routeParams.fetch(transition, 'logged-in.project')
              .projectId,
            page: pageNumber,
          },
        },
      }
    );

    return this.subscription.currentResult();
  }

  deactivate() {
    this.apolloSubscription.clearSubscription(this.subscription);
  }

  @action
  onRefresh() {
    this.refresh();
  }
}
