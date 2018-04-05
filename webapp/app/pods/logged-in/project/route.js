import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import ApolloRoute from 'accent-webapp/mixins/apollo-route';

import projectQuery from 'accent-webapp/queries/project';

const props = data => {
  if (!data.viewer || !data.viewer.project) return {permissions: []};

  const permissions = data.viewer.project.viewerPermissions.reduce((memo, permission) => {
    memo[permission] = true;
    return memo;
  }, {});

  return {project: data.viewer.project, permissions, roles: data.roles, documentFormats: data.documentFormats};
};

export default Route.extend(ApolloRoute, {
  globalState: service('global-state'),

  model(params) {
    return this.graphql(projectQuery, {
      props,
      options: {
        variables: {
          projectId: params.projectId
        }
      }
    });
  },

  actions: {
    refreshModel() {
      this.refresh();
    },

    willTransition() {
      this.set('globalState.isProjectNavigationListShowing', false);
    }
  }
});
