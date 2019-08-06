import {get} from '@ember/object';
import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import ApolloRoute from 'accent-webapp/mixins/apollo-route';

import projectDashboardQuery from 'accent-webapp/queries/project-dashboard';

export default Route.extend(ApolloRoute, {
  routeParams: service(),

  model(_params, transition) {
    return this.graphql(projectDashboardQuery, {
      props: data => ({
        project: get(data, 'viewer.project')
      }),
      options: {
        fetchPolicy: 'cache-and-network',
        variables: {
          projectId: this.routeParams.fetch(transition, 'logged-in.project')
            .projectId
        }
      }
    });
  }
});
