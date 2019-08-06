import {get} from '@ember/object';
import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import ResetScroll from 'accent-webapp/mixins/reset-scroll';
import ApolloRoute from 'accent-webapp/mixins/apollo-route';

import translationsQuery from 'accent-webapp/queries/jipt-translations';

export default Route.extend(ResetScroll, ApolloRoute, {
  routeParams: service(),

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
        project: get(data, 'viewer.project'),
        documents: get(data, 'viewer.project.documents.entries'),
        versions: get(data, 'viewer.project.versions.entries'),
        translations: get(data, 'viewer.project.revision.translations'),
        selectedTranslationIds: transition.queryParams.translationIds
      }),
      options: {
        fetchPolicy: 'cache-and-network',
        variables: {
          projectId: this.routeParams.fetch(transition, 'logged-in.jipt')
            .projectId,
          revisionId: transition.queryParams.revisionId,
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
  }
});
