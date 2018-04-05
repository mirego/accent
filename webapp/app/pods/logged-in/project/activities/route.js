import {get} from '@ember/object';
import Route from '@ember/routing/route';
import ApolloRoute from 'accent-webapp/mixins/apollo-route';

import projectActivitiesQuery from 'accent-webapp/queries/project-activities';

export default Route.extend(ApolloRoute, {
  queryParams: {
    batchFilter: {
      refreshModel: true
    },
    actionFilter: {
      refreshModel: true
    },
    userFilter: {
      refreshModel: true
    },
    page: {
      refreshModel: true
    }
  },

  model({batchFilter, actionFilter, userFilter, page}, transition) {
    return this.graphql(projectActivitiesQuery, {
      props: data => ({
        project: get(data, 'viewer.project'),
        activities: get(data, 'viewer.project.activities'),
        collaborators: get(data, 'viewer.project.collaborators')
      }),
      options: {
        fetchPolicy: 'cache-and-network',
        variables: {
          projectId: transition.params['logged-in.project'].projectId,
          isBatch: batchFilter ? true : null,
          action: actionFilter,
          userId: userFilter,
          page
        }
      }
    });
  },

  resetController(controller, isExiting) {
    if (isExiting) {
      controller.setProperties({
        page: 1
      });
    }
  },

  actions: {
    onRefresh() {
      this.refresh();
    }
  }
});
