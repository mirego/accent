import Route from '@ember/routing/route';
import ApolloRoute from 'accent-webapp/mixins/apollo-route';

import projectQuery from 'accent-webapp/queries/jipt-project';

const props = data => {
  if (!data.viewer || !data.viewer.project) return {permissions: []};

  const permissions = data.viewer.project.viewerPermissions.reduce((memo, permission) => {
    memo[permission] = true;
    return memo;
  }, {});

  return {project: data.viewer.project, permissions, roles: data.roles};
};

export default Route.extend(ApolloRoute, {
  queryParams: {
    revisionId: {
      refreshModel: true
    }
  },

  model(params) {
    return this.graphql(projectQuery, {
      props,
      options: {
        variables: {
          projectId: params.projectId,
          revisionId: params.revisionId
        }
      }
    });
  }
});
