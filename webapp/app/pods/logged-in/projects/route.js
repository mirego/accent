import Route from '@ember/routing/route';
import {inject as service} from '@ember/service';

import projectsQuery from 'accent-webapp/queries/projects';
import Session from 'accent-webapp/services/session';
import ApolloSubscription from 'accent-webapp/services/apollo-subscription';

const props = data => {
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

  model({page, query}) {
    return this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      projectsQuery,
      {
        props: data => {
          if (!data.viewer) {
            this.session.logout();
            return (window.location = '/');
          }

          return props(data);
        },
        options: {
          fetchPolicy: 'network-only',
          variables: {
            page,
            query
          }
        }
      }
    );
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
    this.apolloSubscription.clearSubscription();
  }
}
