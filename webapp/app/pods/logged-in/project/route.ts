import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import {action} from '@ember/object';

import projectQuery, {
  ProjectQueryResponse,
} from 'accent-webapp/queries/project';
import GlobalState from 'accent-webapp/services/global-state';
import ApolloSubscription, {
  Subscription,
} from 'accent-webapp/services/apollo-subscription';

interface RouteParams {
  projectId: string;
}

export default class ProjectRoute extends Route {
  @service('apollo-subscription')
  apolloSubscription: ApolloSubscription;

  @service('global-state')
  globalState: GlobalState;

  subscription: Subscription;

  model(params: RouteParams) {
    const props = (data: any) => this.transformData(data);

    this.subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      projectQuery,
      {
        props,
        options: {
          variables: {
            projectId: params.projectId,
          },
        },
      }
    );

    return this.subscription.currentResult();
  }

  @action
  refreshModel() {
    this.refresh();
  }

  @action
  willTransition() {
    this.globalState.isProjectNavigationListShowing = false;
  }

  deactivate() {
    this.apolloSubscription.clearSubscription(this.subscription);
  }

  private transformData(data: ProjectQueryResponse) {
    if (!data.viewer || !data.viewer.project) return {permissions: []};

    const permissions = data.viewer.project.viewerPermissions.reduce(
      (memo: Record<string, boolean>, permission: string) => {
        memo[permission] = true;
        return memo;
      },
      {}
    );

    // FIXME: These are a side-effects, we should refactor this to avoid having
    // to set state here.
    this.globalState.permissions = permissions;
    this.globalState.mainColor = data.viewer.project.mainColor;
    this.globalState.roles = data.roles;
    this.globalState.documentFormats = data.documentFormats;

    return {
      project: data.viewer.project,
      permissions,
      roles: data.roles,
      documentFormats: data.documentFormats,
    };
  }
}
