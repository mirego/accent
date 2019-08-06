import {get} from '@ember/object';
import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import ApolloRoute from 'accent-webapp/mixins/apollo-route';

import projectNewLanguageQuery from 'accent-webapp/queries/project-new-language';

export default Route.extend(ApolloRoute, {
  routeParams: service(),

  model(_params, transition) {
    return this.graphql(projectNewLanguageQuery, {
      props: data => ({
        project: get(data, 'viewer.project'),
        languages: get(data, 'languages.entries')
      }),
      options: {
        fetchPolicy: 'cache-and-network',
        variables: {
          projectId: this.routeParams.fetch(transition, 'logged-in.project')
            .projectId
        }
      }
    });
  },

  resetController(controller, isExiting) {
    if (isExiting) {
      controller.setProperties({
        errors: []
      });
    }
  },

  actions: {
    onRefresh() {
      this.refresh();
    }
  }
});
