import {get} from '@ember/object';
import Route from '@ember/routing/route';
import ResetScroll from 'accent-webapp/mixins/reset-scroll';
import ApolloRoute from 'accent-webapp/mixins/apollo-route';

import translationsQuery from 'accent-webapp/queries/conflicts';

export default Route.extend(ResetScroll, ApolloRoute, {
  queryParams: {
    fullscreen: {
      refreshModel: true
    },
    query: {
      refreshModel: true
    },
    page: {
      refreshModel: true
    },
    reference: {
      refreshModel: true
    },
    document: {
      refreshModel: true
    }
  },

  model({query, page, reference, document}, transition) {
    return this.graphql(translationsQuery, {
      props: data => ({
        revisionId: transition.params['logged-in.project.revision'].revisionId,
        referenceRevisionId: reference,
        revisionModel: this.modelFor('logged-in.project.revision'),
        documents: get(data, 'viewer.project.documents.entries'),
        project: get(data, 'viewer.project'),
        translations: get(data, 'viewer.project.revision.translations')
      }),
      options: {
        fetchPolicy: 'cache-and-network',
        variables: {
          projectId: transition.params['logged-in.project'].projectId,
          revisionId:
            transition.params['logged-in.project.revision'].revisionId,
          query,
          page,
          document,
          reference
        }
      }
    });
  },

  renderTemplate(controller) {
    if (controller.fullscreen) {
      this.render('logged-in.project.revision.full-screen-conflicts', {
        controller,
        outlet: 'main'
      });
    } else {
      return this._super(...arguments);
    }
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

      this.transitionTo(
        'logged-in.project.revision.conflicts',
        project.id,
        revisionId
      );
    },

    refresh() {
      this.refresh();
    }
  }
});
