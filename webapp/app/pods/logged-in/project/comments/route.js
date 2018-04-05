import {get} from '@ember/object';
import Route from '@ember/routing/route';
import ApolloRoute from 'accent-webapp/mixins/apollo-route';

import projectCommentsQuery from 'accent-webapp/queries/project-comments';

export default Route.extend(ApolloRoute, {
  queryParams: {
    page: {
      refreshModel: true
    }
  },

  model({page}, transition) {
    if (page) page = parseInt(page, 10);

    return this.graphql(projectCommentsQuery, {
      props: data => ({
        comments: get(data, 'viewer.project.comments'),
        project: get(data, 'viewer.project')
      }),
      options: {
        fetchPolicy: 'cache-and-network',
        variables: {
          projectId: transition.params['logged-in.project'].projectId,
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
  }
});
