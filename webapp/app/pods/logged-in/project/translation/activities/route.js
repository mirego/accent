import {get} from '@ember/object';
import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import ApolloRoute from 'accent-webapp/mixins/apollo-route';

import translationActivitiesQuery from 'accent-webapp/queries/translation-activities';

export default Route.extend(ApolloRoute, {
  apollo: service(),

  queryParams: {
    page: {
      refreshModel: true
    }
  },

  model({page}, transition) {
    return this.graphql(translationActivitiesQuery, {
      props: data => ({
        project: get(data, 'viewer.project'),
        activities: get(data, 'viewer.project.translation.activities')
      }),
      options: {
        fetchPolicy: 'cache-and-network',
        variables: {
          projectId: transition.params['logged-in.project'].projectId,
          translationId: transition.params['logged-in.project.translation'].translationId,
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
