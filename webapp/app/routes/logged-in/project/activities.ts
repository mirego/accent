import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';

import projectActivitiesQuery from 'accent-webapp/queries/project-activities';
import RouteParams from 'accent-webapp/services/route-params';
import Transition from '@ember/routing/transition';
import ApolloSubscription, {
  Subscription
} from 'accent-webapp/services/apollo-subscription';
import ActivitiesController from 'accent-webapp/controllers/logged-in/project/activities';

export default class ActivitiesRoute extends Route {
  @service('apollo-subscription')
  apolloSubscription: ApolloSubscription;

  @service('route-params')
  routeParams: RouteParams;

  queryParams = {
    batchFilter: {
      refreshModel: true
    },
    actionFilter: {
      refreshModel: true
    },
    userFilter: {
      refreshModel: true
    },
    versionFilter: {
      refreshModel: true
    },
    page: {
      refreshModel: true
    }
  };

  subscription: Subscription;

  model(
    {
      batchFilter,
      actionFilter,
      userFilter,
      versionFilter,
      page
    }: {
      batchFilter: any;
      actionFilter: any;
      userFilter: any;
      versionFilter: any;
      page: number;
    },
    transition: Transition
  ) {
    if (this.subscription)
      this.apolloSubscription.clearSubscription(this.subscription);

    this.subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      projectActivitiesQuery,
      {
        props: (data) => ({
          project: data.viewer.project,
          activities: data.viewer.project.activities,
          collaborators: data.viewer.project.collaborators,
          versions: data.viewer.project.versions.entries
        }),
        options: {
          fetchPolicy: 'cache-and-network',
          variables: {
            projectId: this.routeParams.fetch(transition, 'logged-in.project')
              .projectId,
            isBatch: batchFilter ? true : null,
            action: actionFilter === '' ? null : actionFilter,
            userId: userFilter === '' ? null : userFilter,
            versionId: versionFilter === '' ? null : versionFilter,
            page
          }
        }
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
