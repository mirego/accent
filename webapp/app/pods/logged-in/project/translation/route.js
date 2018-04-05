import {get} from '@ember/object';
import Route from '@ember/routing/route';
import ApolloRoute from 'accent-webapp/mixins/apollo-route';

import translationQuery from 'accent-webapp/queries/translation';

export default Route.extend(ApolloRoute, {
  model({translationId}, transition) {
    return this.graphql(translationQuery, {
      props: data => ({
        project: get(data, 'viewer.project'),
        translation: get(data, 'viewer.project.translation')
      }),
      options: {
        fetchPolicy: 'cache-and-network',
        variables: {
          projectId: transition.params['logged-in.project'].projectId,
          translationId
        }
      }
    });
  }
});
