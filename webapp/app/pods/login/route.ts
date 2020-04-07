import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';

import authenticationProvidersQuery from 'accent-webapp/queries/authentication-providers';
import ApolloSubscription, {
  Subscription,
} from 'accent-webapp/services/apollo-subscription';
import Session from 'accent-webapp/services/session';

export default class LoginRoute extends Route {
  @service('session')
  session: Session;

  @service('apollo-subscription')
  apolloSubscription: ApolloSubscription;

  subscription: Subscription;

  model() {
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
      this.transitionTo('logged-in.projects');
    }
  }
}
