import {service} from '@ember/service';
import Route from '@ember/routing/route';

import authenticationProvidersQuery from 'accent-webapp/queries/authentication-providers';
import ApolloSubscription, {
  Subscription
} from 'accent-webapp/services/apollo-subscription';
import Session from 'accent-webapp/services/session';
import RouterService from '@ember/routing/router-service';

export default class LoginRoute extends Route {
  @service('session')
  declare session: Session;

  @service('router')
  declare router: RouterService;

  @service('apollo-subscription')
  declare apolloSubscription: ApolloSubscription;

  subscription: Subscription;

  model() {
    if (this.subscription)
      this.apolloSubscription.clearSubscription(this.subscription);

    this.subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      authenticationProvidersQuery,
      {}
    );

    return this.subscription.currentResult();
  }

  deactivate() {
    this.apolloSubscription.clearSubscription(this.subscription);
  }

  redirect() {
    if (this.session.isAuthenticated) {
      this.router.transitionTo('logged-in.projects');
    }
  }
}
