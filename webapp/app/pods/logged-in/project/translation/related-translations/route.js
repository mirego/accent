import {get} from '@ember/object';
import Route from '@ember/routing/route';
import ApolloRoute from 'accent-webapp/mixins/apollo-route';

import relatedTranslationsQuery from 'accent-webapp/queries/related-translations';

export default Route.extend(ApolloRoute, {
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
          projectId: transition.params['logged-in.project'].projectId,
          translationId:
            transition.params['logged-in.project.translation'].translationId
        }
      }
    });
  }
});
