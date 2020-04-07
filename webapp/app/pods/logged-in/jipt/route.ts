import Route from '@ember/routing/route';
import {inject as service} from '@ember/service';

import projectQuery from 'accent-webapp/queries/jipt-project';
import ApolloSubscription, {
  Subscription,
} from 'accent-webapp/services/apollo-subscription';
import JIPT from 'accent-webapp/services/jipt';
import GlobalState from 'accent-webapp/services/global-state';

export default class JIPTRoute extends Route {
  @service('apollo-subscription')
  apolloSubscription: ApolloSubscription;

  @service('jipt')
  jipt: JIPT;

  @service('global-state')
  globalState: GlobalState;

  queryParams = {
    revisionId: {
      refreshModel: true,
    },
  };

  subscription: Subscription;

  model(params: any) {
    this.subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      projectQuery,
      {
        props: (data) => this.props(data),
        options: {
          variables: {
            projectId: params.projectId,
            revisionId: params.revisionId,
          },
        },
      }
    );

    return this.subscription.currentResult();
  }

  deactivate() {
    this.apolloSubscription.clearSubscription(this.subscription);
  }

  private props(data: any) {
    if (!data.viewer || !data.viewer.project) return {permissions: []};

    this.jipt.listTranslations(
      data.viewer.project.revision.translations.entries,
      data.viewer.project.revision
    );

    const permissions = data.viewer.project.viewerPermissions.reduce(
      (memo: Record<string, true>, permission: string) => {
        memo[permission] = true;
        return memo;
      },
      {}
    );

    this.globalState.permissions = permissions;
    this.globalState.mainColor = data.viewer.project.mainColor;

    return {project: data.viewer.project, permissions, roles: data.roles};
  }
}
