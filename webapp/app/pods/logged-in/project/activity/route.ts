import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';

import projectActivityQuery from 'accent-webapp/queries/project-activity';
import RouteParams from 'accent-webapp/services/route-params';
import ApolloSubscription, {
  Subscription,
} from 'accent-webapp/services/apollo-subscription';
import Transition from '@ember/routing/-private/transition';

export default class Activity extends Route {
  @service('apollo-subscription')
  apolloSubscription: ApolloSubscription;

  @service('route-params')
  routeParams: RouteParams;

  subscription: Subscription;

  model({activityId}: {activityId: string}, transition: Transition) {
    this.subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      projectActivityQuery,
      {
        props: (data) => ({
          project: data.viewer.project,
          activity: data.viewer.project.activity,
        }),
        options: {
          fetchPolicy: 'cache-and-network',
          variables: {
            projectId: this.routeParams.fetch(transition, 'logged-in.project')
              .projectId,
            activityId,
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
