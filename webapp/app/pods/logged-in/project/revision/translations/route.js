import {get} from '@ember/object';
import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import ResetScroll from 'accent-webapp/mixins/reset-scroll';
import ApolloRoute from 'accent-webapp/mixins/apollo-route';

import translationsQuery from 'accent-webapp/queries/translations';

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
    },
    isTextEmpty: {
      refreshModel: true
    },
    isTextNotEmpty: {
      refreshModel: true
    },
    isAddedLastSync: {
      refreshModel: true
    },
    isCommentedOn: {
      refreshModel: true
    }
  },

  model(params, transition) {
    params.isTextEmpty = params.isTextEmpty === 'true' ? true : null;
    params.isTextNotEmpty = params.isTextNotEmpty === 'true' ? true : null;
    params.isAddedLastSync = params.isAddedLastSync === 'true' ? true : null;
    params.isCommentedOn = params.isCommentedOn === 'true' ? true : null;

    return this.graphql(translationsQuery, {
      props: data => ({
        revisionId: this.routeParams.fetch(
          transition,
          'logged-in.project.revision'
        ).revisionId,
        project: get(data, 'viewer.project'),
        documents: get(data, 'viewer.project.documents.entries'),
        versions: get(data, 'viewer.project.versions.entries'),
        translations: get(data, 'viewer.project.revision.translations')
      }),
      options: {
        fetchPolicy: 'cache-and-network',
        variables: {
          projectId: this.routeParams.fetch(transition, 'logged-in.project')
            .projectId,
          revisionId: this.routeParams.fetch(
            transition,
            'logged-in.project.revision'
          ).revisionId,
          ...params
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

      this.transitionTo(
        'logged-in.project.revision.translations',
        project.id,
        revisionId
      );
    }
  }
});
