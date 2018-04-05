import {get} from '@ember/object';
import Route from '@ember/routing/route';
import ResetScroll from 'accent-webapp/mixins/reset-scroll';
import ApolloRoute from 'accent-webapp/mixins/apollo-route';

import translationsQuery from 'accent-webapp/queries/translations';

export default Route.extend(ResetScroll, ApolloRoute, {
  queryParams: {
    query: {
      refreshModel: true
    },
    page: {
      refreshModel: true
    },
    document: {
      refreshModel: true
    },
    version: {
      refreshModel: true
    }
  },

  model({query, page, document, version}, transition) {
    return this.graphql(translationsQuery, {
      props: data => ({
        revisionId: transition.params['logged-in.project.revision'].revisionId,
        project: get(data, 'viewer.project'),
        documents: get(data, 'viewer.project.documents.entries'),
        versions: get(data, 'viewer.project.versions.entries'),
        translations: get(data, 'viewer.project.revision.translations')
      }),
      options: {
        fetchPolicy: 'cache-and-network',
        variables: {
          projectId: transition.params['logged-in.project'].projectId,
          revisionId: transition.params['logged-in.project.revision'].revisionId,
          query,
          page,
          document,
          version
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
    onRevisionChange({revisionId}) {
      const {project} = this.modelFor('logged-in.project');

      this.transitionTo('logged-in.project.revision.translations', project.id, revisionId);
    }
  }
});
