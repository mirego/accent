import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';

import translationCommentsQuery from 'accent-webapp/queries/translation-comments';
import ApolloSubscription, {
  Subscription,
} from 'accent-webapp/services/apollo-subscription';
import RouteParams from 'accent-webapp/services/route-params';
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
      translationCommentsQuery,
      {
        props: (data) => ({
          translation: data.viewer.project.translation,
          comments: data.viewer.project.translation.comments,
          collaborators: data.viewer.project.collaborators,
          commentsSubscriptions:
            data.viewer.project.translation.commentsSubscriptions,
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
            page: pageNumber,
          },
        },
      }
    );

    return this.subscription.currentResult();
  }

  resetController(controller: CommentsController, isExiting: boolean) {
    if (isExiting) {
      controller.page = null;
    }
  }

  @action
  onRefresh() {
    this.refresh();
  }
}
