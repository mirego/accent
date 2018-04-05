import Route from '@ember/routing/route';
import ApolloRoute from 'accent-webapp/mixins/apollo-route';
import AuthenticatedRoute from 'accent-webapp/mixins/authenticated-route';

import projectsQuery from 'accent-webapp/queries/projects';

export default Route.extend(ApolloRoute, AuthenticatedRoute, {
  queryParams: {
    query: {
      refreshModel: true
    },
    page: {
      refreshModel: true
    }
  },

  model({page, query}) {
    return this.graphql(projectsQuery, {
      props: data => {
        if (!data.viewer) {
          this.session.logout();
          return (window.location = '/');
        }

        return {
          projects: data.viewer.projects,
          languages: data.languages.entries
        };
      },
      options: {
        fetchPolicy: 'network-only',
        variables: {
          page,
          query
        }
      }
    });
  },

  resetController(controller, isExiting) {
    if (isExiting) {
      controller.setProperties({
        query: '',
        page: 1
      });
    }
  }
});
