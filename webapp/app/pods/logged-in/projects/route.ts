import Route from '@ember/routing/route';
import {inject as service} from '@ember/service';

import projectsQuery from 'accent-webapp/queries/projects';
import Session from 'accent-webapp/services/session';
import ApolloSubscription, {
  Subscription,
} from 'accent-webapp/services/apollo-subscription';
import ProjectsController from 'accent-webapp/pods/logged-in/projects/controller';

const transformData = (data: any) => {
  const permissions = data.viewer.permissions.reduce(
    (memo: any, permission: any) => {
      memo[permission] = true;
      return memo;
    },
    {}
  );

  return {
    projects: data.viewer.projects,
    languages: data.languages.entries,
    permissions,
  };
};

export default class ProjectsRoute extends Route {
  @service('session')
  session: Session;

  @service('apollo-subscription')
  apolloSubscription: ApolloSubscription;

  queryParams = {
    query: {
      refreshModel: true,
    },
    page: {
      refreshModel: true,
    },
  };

  subscription: Subscription;

  model({page, query}: {page: number; query: any}) {
    const props = (data: any) => {
      if (!data.viewer) {
        this.session.logout();

        window.location.href = '/';

        return;
      }

      return transformData(data);
    };

    this.subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      projectsQuery,
      {
        props,
        options: {
          fetchPolicy: 'network-only',
          variables: {
            page,
            query,
          },
        },
      }
    );

    return this.subscription.currentResult();
  }

  redirect() {
    if (!this.session.isAuthenticated) {
      this.transitionTo('login');
    }
  }

  resetController(controller: ProjectsController, isExiting: boolean) {
    if (isExiting) {
      controller.query = '';
      controller.page = 1;
    }
  }

  deactivate() {
    this.apolloSubscription.clearSubscription(this.subscription);
  }
}
