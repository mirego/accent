import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';

import projectActivitiesQuery from 'accent-webapp/queries/project-activities';
import RouteParams from 'accent-webapp/services/route-params';
import Transition from '@ember/routing/-private/transition';
import ApolloSubscription, {
  Subscription,
} from 'accent-webapp/services/apollo-subscription';
import ActivitiesController from 'accent-webapp/pods/logged-in/project/activities/controller';

export default class ActivitiesRoute extends Route {
  @service('apollo-subscription')
  apolloSubscription: ApolloSubscription;

  @service('route-params')
  routeParams: RouteParams;

  queryParams = {
    batchFilter: {
      refreshModel: true,
    },
    actionFilter: {
      refreshModel: true,
    },
    userFilter: {
      refreshModel: true,
    },
    page: {
      refreshModel: true,
    },
  };

  subscription: Subscription;

  model(
    {
      batchFilter,
      actionFilter,
      userFilter,
      page,
    }: {batchFilter: any; actionFilter: any; userFilter: any; page: number},
    transition: Transition
  ) {
    this.subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      projectActivitiesQuery,
      {
        props: (data) => ({
          project: data.viewer.project,
          activities: data.viewer.project.activities,
          collaborators: data.viewer.project.collaborators,
        }),
        options: {
          fetchPolicy: 'cache-and-network',
          variables: {
            projectId: this.routeParams.fetch(transition, 'logged-in.project')
              .projectId,
            isBatch: batchFilter ? true : null,
            action: actionFilter,
            userId: userFilter,
            page,
          },
        },
      }
    );

    return this.subscription.currentResult();
  }

  resetController(controller: ActivitiesController, isExiting: boolean) {
    if (isExiting) {
      controller.page = 1;
    }
  }

  deactivate() {
    this.apolloSubscription.clearSubscription(this.subscription);
  }

  @action
  onRefresh() {
    this.refresh();
  }
}
