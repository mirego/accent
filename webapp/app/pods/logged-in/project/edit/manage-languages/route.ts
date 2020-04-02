import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';

import projectNewLanguageQuery from 'accent-webapp/queries/project-new-language';
import RouteParams from 'accent-webapp/services/route-params';
import ApolloSubscription, {
  Subscription,
} from 'accent-webapp/services/apollo-subscription';
import Transition from '@ember/routing/-private/transition';
import ManageLanguagesController from 'accent-webapp/pods/logged-in/project/edit/manage-languages/controller';

export default class ManageLanguagesRoute extends Route {
  @service('apollo-subscription')
  apolloSubscription: ApolloSubscription;

  @service('route-params')
  routeParams: RouteParams;

  subscription: Subscription;

  model(_params: any, transition: Transition) {
    this.subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      projectNewLanguageQuery,
      {
        props: (data) => ({
          project: data.viewer.project,
          languages: data.languages.entries,
        }),
        options: {
          fetchPolicy: 'cache-and-network',
          variables: {
            projectId: this.routeParams.fetch(transition, 'logged-in.project')
              .projectId,
          },
        },
      }
    );

    return this.subscription.currentResult();
  }

  resetController(controller: ManageLanguagesController, isExiting: boolean) {
    if (isExiting) {
      controller.errors = [];
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
