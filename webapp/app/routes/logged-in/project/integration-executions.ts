import {service} from '@ember/service';
import Route from '@ember/routing/route';

import integrationExecutionsQuery from 'accent-webapp/queries/integration-executions';
import RouteParams from 'accent-webapp/services/route-params';
import ApolloSubscription, {
  Subscription
} from 'accent-webapp/services/apollo-subscription';
import Transition from '@ember/routing/transition';
import IntegrationExecutionsController from 'accent-webapp/controllers/logged-in/project/integration-executions';

export default class IntegrationExecutionsRoute extends Route {
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

  model(
    {integrationId, page}: {integrationId: string; page: string},
    transition: Transition
  ) {
    if (this.subscription)
      this.apolloSubscription.clearSubscription(this.subscription);

    const pageNumber = page ? parseInt(page, 10) : null;

    this.subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      integrationExecutionsQuery,
      {
        props: (data) => {
          const project = data.viewer.project;
          const integration = project.integrations.find(
            (i: any) => i.id === integrationId
          );

          return {
            project,
            integration,
            executions: integration?.integrationExecutions
          };
        },
        options: {
          fetchPolicy: 'cache-and-network',
          variables: {
            projectId: this.routeParams.fetch(transition, 'logged-in.project')
              .projectId,
            page: pageNumber
          }
        }
      }
    );

    return this.subscription.currentResult();
  }

  deactivate() {
    this.apolloSubscription.clearSubscription(this.subscription);
  }

  resetController(
    controller: IntegrationExecutionsController,
    isExiting: boolean
  ) {
    if (isExiting) {
      controller.page = 1;
    }
  }
}
