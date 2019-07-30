import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import ApolloRoute from 'accent-webapp/mixins/apollo-route';

import authenticationProvidersQuery from 'accent-webapp/queries/authentication-providers';

export default Route.extend(ApolloRoute, {
  session: service('session'),

  model() {
    return this.graphql(authenticationProvidersQuery, {});
  },

  redirect() {
    if (this.session.isAuthenticated) {
      this.transitionTo('logged-in.projects');
    }
  }
});
