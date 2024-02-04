import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';

import translationEditionsQuery from 'accent-webapp/queries/translation-editions';
import ApolloSubscription, {
  Subscription,
} from 'accent-webapp/services/apollo-subscription';
import RouteParams from 'accent-webapp/services/route-params';
import TranslationsController from 'accent-webapp/pods/logged-in/project/revision/translations/controller';
import RouterService from '@ember/routing/router-service';
import Transition from '@ember/routing/-private/transition';

export default class TranslationEditionsRoute extends Route {
  @service('apollo-subscription')
  apolloSubscription: ApolloSubscription;

  @service('route-params')
  routeParams: RouteParams;

  @service('router')
  router: RouterService;

  subscription: Subscription;

  model(_params: any, transition: Transition) {
    this.subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      translationEditionsQuery,
      {
        props: (data) => ({
          revisionModel: this.modelFor('logged-in.project.revision'),
          project: data.viewer.project,
          prompts: data.viewer.project.prompts,
          translations: data.viewer.project.translation.editions,
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
          },
        },
      }
    );

    return this.subscription.currentResult();
  }

  resetController(controller: TranslationsController, isExiting: boolean) {
    if (isExiting) {
      controller.page = 1;
    }
  }

  activate() {
    window.scrollTo(0, 0);
  }

  deactivate() {
    this.apolloSubscription.clearSubscription(this.subscription);
  }
}
