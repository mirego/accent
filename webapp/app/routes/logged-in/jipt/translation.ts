import {service} from '@ember/service';
import Route from '@ember/routing/route';

import translationQuery from 'accent-webapp/queries/translation';
import ApolloSubscription, {
  Subscription
} from 'accent-webapp/services/apollo-subscription';
import RouteParams from 'accent-webapp/services/route-params';
import Transition from '@ember/routing/transition';

export default class TranslationRoute extends Route {
  @service('apollo-subscription')
  declare apolloSubscription: ApolloSubscription;

  @service('route-params')
  declare routeParams: RouteParams;

  subscription: Subscription;

  model({translationId}: {translationId: string}, transition: Transition) {
    if (this.subscription)
      this.apolloSubscription.clearSubscription(this.subscription);

    this.subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      translationQuery,
      {
        props: (data) => ({
          project: data.viewer.project,
          translation: data.viewer.project.translation,
          revisions: data.viewer.project.revisions,
          prompts: data.viewer.project.prompts
        }),
        options: {
          fetchPolicy: 'cache-and-network',
          variables: {
            projectId: this.routeParams.fetch(transition, 'logged-in.jipt')
              .projectId,
            translationId
          }
        }
      }
    );

    return this.subscription.currentResult();
  }

  deactivate() {
    this.apolloSubscription.clearSubscription(this.subscription);
  }
}
