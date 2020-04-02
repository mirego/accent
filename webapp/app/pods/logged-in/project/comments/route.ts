import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';

import projectCommentsQuery from 'accent-webapp/queries/project-comments';
import RouteParams from 'accent-webapp/services/route-params';
import ApolloSubscription, {
  Subscription,
} from 'accent-webapp/services/apollo-subscription';
import Transition from '@ember/routing/-private/transition';
import CommentsController from 'accent-webapp/pods/logged-in/project/comments/controller';

export default class CommentsRoute extends Route {
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
      projectCommentsQuery,
      {
        props: (data) => ({
          comments: data.viewer.project.comments,
          project: data.viewer.project,
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

  resetController(controller: CommentsController, isExiting: boolean) {
    if (isExiting) {
      controller.page = 1;
    }
  }
}
