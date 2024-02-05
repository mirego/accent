import Route from '@ember/routing/route';
import {inject as service} from '@ember/service';

import projectsQuery from 'accent-webapp/queries/projects';
import Session from 'accent-webapp/services/session';
import ApolloSubscription, {
  Subscription,
} from 'accent-webapp/services/apollo-subscription';
import ProjectsController from 'accent-webapp/controllers/logged-in/projects';
import RecentProjects from 'accent-webapp/services/recent-projects';
import RouterService from '@ember/routing/router-service';

const transformData = (data: any, recentProjectIds: string[]) => {
  const permissions = data.viewer.permissions.reduce(
    (memo: any, permission: any) => {
      memo[permission] = true;
      return memo;
    },
    {}
  );

  const orderedProjects = (recentProjectId: string) => {
    return data.viewer.projects.nodes.find(
      ({id}: {id: string}) => recentProjectId === id
    );
  };

  const recentProjects = recentProjectIds.map(orderedProjects).filter(Boolean);

  return {
    projects: data.viewer.projects,
    languages: data.languages.entries,
    recentProjects,
    permissions,
  };
};

export default class ProjectsRoute extends Route {
  @service('session')
  session: Session;

  @service('recent-projects')
  recentProjects: RecentProjects;

  @service('apollo-subscription')
  apolloSubscription: ApolloSubscription;

  @service('router')
  router: RouterService;

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
    const recentProjectIds = this.recentProjects.fetch();

    const props = (data: any) => {
      if (!data.viewer) {
        this.session.logout();

        window.location.href = '/';

        return;
      }

      return transformData(data, recentProjectIds);
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
            nodeIds: recentProjectIds,
          },
        },
      }
    );

    return this.subscription.currentResult();
  }

  redirect() {
    if (!this.session.isAuthenticated) {
      this.router.transitionTo('login');
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
