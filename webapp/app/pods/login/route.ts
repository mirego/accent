import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';

import authenticationProvidersQuery from 'accent-webapp/queries/authentication-providers';
import ApolloSubscription from 'accent-webapp/services/apollo-subscription';
import Session from 'accent-webapp/services/session';

export default class LoginRoute extends Route {
  @service('session')
  session: Session;

  @service('apollo-subscription')
  apolloSubscription: ApolloSubscription;

  model() {
    return this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      authenticationProvidersQuery,
      {}
    );
  }

  deactivate() {
    this.apolloSubscription.clearSubscription();
  }

  redirect() {
    if (this.session.isAuthenticated) {
      this.transitionTo('logged-in.projects');
    }
  }
}
