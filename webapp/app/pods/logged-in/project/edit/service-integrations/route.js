import {get} from '@ember/object';
import Route from '@ember/routing/route';
import ApolloRoute from 'accent-webapp/mixins/apollo-route';

import projectServiceIntegrationsQuery from 'accent-webapp/queries/project-service-integrations';

export default Route.extend(ApolloRoute, {
  model(_params, transition) {
    return this.graphql(projectServiceIntegrationsQuery, {
      props: data => ({
        project: get(data, 'viewer.project')
      }),
      options: {
        fetchPolicy: 'cache-and-network',
        variables: {
          projectId: this.routeParams.fetch(transition, 'logged-in.project').projectId
        }
      }
    });
  },

  actions: {
    onRefresh() {
      this.refresh();
    }
  }
});
