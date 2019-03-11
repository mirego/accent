import {get} from '@ember/object';
import Route from '@ember/routing/route';
import ApolloRoute from 'accent-webapp/mixins/apollo-route';

import translationCommentsQuery from 'accent-webapp/queries/translation-comments';

export default Route.extend(ApolloRoute, {
  queryParams: {
    page: {
      refreshModel: true
    }
  },

  model({page}, transition) {
    if (page) page = parseInt(page, 10);

    return this.graphql(translationCommentsQuery, {
      props: data => ({
        translation: get(data, 'viewer.project.translation'),
        comments: get(data, 'viewer.project.translation.comments'),
        collaborators: get(data, 'viewer.project.collaborators'),
        commentsSubscriptions: get(
          data,
          'viewer.project.translation.commentsSubscriptions'
        )
      }),
      options: {
        fetchPolicy: 'cache-and-network',
        variables: {
          projectId: transition.params['logged-in.project'].projectId,
          translationId:
            transition.params['logged-in.project.translation'].translationId,
          page
        }
      }
    });
  },

  resetController(controller, isExiting) {
    if (isExiting) {
      controller.setProperties({
        page: null
      });
    }
  },

  actions: {
    onRefresh() {
      this.refresh();
    }
  }
});
