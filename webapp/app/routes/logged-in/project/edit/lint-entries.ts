import {service} from '@ember/service';
import Route from '@ember/routing/route';
import Transition from '@ember/routing/transition';

import projectLintEntriesQuery from 'accent-webapp/queries/project-lint-entries';
import RouteParams from 'accent-webapp/services/route-params';
import ApolloSubscription, {
  Subscription
} from 'accent-webapp/services/apollo-subscription';
import LintEntriesController from 'accent-webapp/controllers/logged-in/project/edit/lint-entries';

export default class LintEntriesRoute extends Route {
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

  model({page}: {page: number}, transition: Transition) {
    if (this.subscription)
      this.apolloSubscription.clearSubscription(this.subscription);

    this.subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      projectLintEntriesQuery,
      {
        props: (data) => ({
          project: data.viewer.project,
          lintEntries: data.viewer.project.lintEntries
        }),
        options: {
          fetchPolicy: 'cache-and-network',
          variables: {
            projectId: this.routeParams.fetch(transition, 'logged-in.project')
              .projectId,
            page
          }
        }
      }
    );

    return this.subscription.currentResult();
  }

  resetController(controller: LintEntriesController, isExiting: boolean) {
    if (isExiting) {
      controller.page = 1;
    }
  }

  deactivate() {
    this.apolloSubscription.clearSubscription(this.subscription);
  }
}
