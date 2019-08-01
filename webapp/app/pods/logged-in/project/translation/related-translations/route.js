import {get} from '@ember/object';
import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import ApolloRoute from 'accent-webapp/mixins/apollo-route';

import relatedTranslationsQuery from 'accent-webapp/queries/related-translations';

export default Route.extend(ApolloRoute, {
  routeParams: service(),

  model(_params, transition) {
    return this.graphql(relatedTranslationsQuery, {
      props: data => ({
        project: get(data, 'viewer.project'),
        relatedTranslations: get(
          data,
          'viewer.project.translation.relatedTranslations'
        )
      }),
      options: {
        fetchPolicy: 'cache-and-network',
        variables: {
          projectId: this.routeParams.fetch(transition, 'logged-in.project').projectId,
          translationId:
            this.routeParams.fetch(transition, 'logged-in.project.translation').translationId
        }
      }
    });
  }
});
