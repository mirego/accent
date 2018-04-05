import {get} from '@ember/object';
import Route from '@ember/routing/route';
import ApolloRoute from 'accent-webapp/mixins/apollo-route';

import projectDashboardQuery from 'accent-webapp/queries/project-dashboard';

export default Route.extend(ApolloRoute, {
  model(_params, transition) {
    return this.graphql(projectDashboardQuery, {
      props: data => ({
        project: get(data, 'viewer.project')
      }),
      options: {
        fetchPolicy: 'cache-and-network',
        variables: {
          projectId: transition.params['logged-in.project'].projectId
        }
      }
    });
  }
});
