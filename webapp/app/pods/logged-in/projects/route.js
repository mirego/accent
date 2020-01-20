import Route from '@ember/routing/route';
import {inject as service} from '@ember/service';

import projectsQuery from 'accent-webapp/queries/projects';
import Session from 'accent-webapp/services/session';
import ApolloSubscription, {
  Subscription
} from 'accent-webapp/services/apollo-subscription';

const transformData = data => {
  const permissions = data.viewer.permissions.reduce((memo, permission) => {
    memo[permission] = true;
    return memo;
  }, {});

  return {
    projects: data.viewer.projects,
    languages: data.languages.entries,
    permissions
  };
};

export default class ProjectsRoute extends Route {
  @service('session')
  session: Session;

  @service('apollo-subscription')
  apolloSubscription: ApolloSubscription;

  queryParams = {
    query: {
      refreshModel: true
    },
    page: {
      refreshModel: true
    }
  };

  subscription: Subscription;

  model({page, query}) {
    const props = data => {
      if (!data.viewer) {
        this.session.logout();
        return (window.location = '/');
      }

      return transformData(data);
    };

    const subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      projectsQuery,
      {
        props,
        options: {
          fetchPolicy: 'network-only',
          variables: {
            page,
            query
          }
        }
      }
    );

    return subscription.currentResult();
  }

  redirect() {
    if (!this.session.isAuthenticated) {
      this.transitionTo('login');
    }
  }

  resetController(controller, isExiting) {
    if (isExiting) {
      controller.setProperties({
        query: '',
        page: 1
      });
    }
  }

  deactivate() {
    this.apolloSubscription.clearSubscription(this.subscription);
  }
}
