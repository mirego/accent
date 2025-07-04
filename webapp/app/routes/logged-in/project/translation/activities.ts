import {action} from '@ember/object';
import {service} from '@ember/service';
import Route from '@ember/routing/route';

import translationActivitiesQuery from 'accent-webapp/queries/translation-activities';
import ApolloSubscription, {
  Subscription
} from 'accent-webapp/services/apollo-subscription';
import RouteParams from 'accent-webapp/services/route-params';
import Transition from '@ember/routing/transition';
import ActivitiesController from 'accent-webapp/controllers/logged-in/project/activities';

export default class ActivitiesRoute extends Route {
  @service('apollo-subscription')
  declare apolloSubscription: ApolloSubscription;

  @service('route-params')
  declare routeParams: RouteParams;

  queryParams = {
    page: {
      refreshModel: true
    }
  };

  subscription: Subscription;

  model({page}: {page: string}, transition: Transition) {
    if (this.subscription)
      this.apolloSubscription.clearSubscription(this.subscription);

    this.subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      translationActivitiesQuery,
      {
        props: (data) => ({
          project: data.viewer.project,
          activities: data.viewer.project.translation.activities
        }),
        options: {
          fetchPolicy: 'cache-and-network',
          variables: {
            projectId: this.routeParams.fetch(transition, 'logged-in.project')
              .projectId,
            translationId: this.routeParams.fetch(
              transition,
              'logged-in.project.translation'
            ).translationId,
            page
          }
        }
      }
    );

    return this.subscription.currentResult();
  }

  deactivate() {
    this.apolloSubscription.clearSubscription(this.subscription);
  }

  resetController(controller: ActivitiesController, isExiting: boolean) {
    if (isExiting) {
      controller.page = 1;
    }
  }

  @action
  onRefresh() {
    this.refresh();
  }
}
