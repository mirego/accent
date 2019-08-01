import {get} from '@ember/object';
import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import ApolloRoute from 'accent-webapp/mixins/apollo-route';

import projectVersionsQuery from 'accent-webapp/queries/project-versions';

export default Route.extend(ApolloRoute, {
  routeParams: service(),

  queryParams: {
    page: {
      refreshModel: true
    }
  },

  model({page}, transition) {
    if (page) page = parseInt(page, 10);

    return this.graphql(projectVersionsQuery, {
      props: data => ({
        project: get(data, 'viewer.project'),
        versions: get(data, 'viewer.project.versions'),
        documents: get(data, 'viewer.project.documents')
      }),
      options: {
        fetchPolicy: 'cache-and-network',
        variables: {
          projectId: this.routeParams.fetch(transition, 'logged-in.project').projectId,
          page
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
