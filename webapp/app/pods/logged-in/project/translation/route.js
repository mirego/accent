import {get} from '@ember/object';
import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import ApolloRoute from 'accent-webapp/mixins/apollo-route';

import translationQuery from 'accent-webapp/queries/translation';

export default Route.extend(ApolloRoute, {
  routeParams: service(),

  model({translationId}, transition) {
    return this.graphql(translationQuery, {
      props: data => ({
        project: get(data, 'viewer.project'),
        translation: get(data, 'viewer.project.translation')
      }),
      options: {
        fetchPolicy: 'cache-and-network',
        variables: {
          projectId: this.routeParams.fetch(transition, 'logged-in.project')
            .projectId,
          translationId
        }
      }
    });
  }
});
