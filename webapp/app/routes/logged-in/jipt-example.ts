import Route from '@ember/routing/route';
import {inject as service} from '@ember/service';

import jiptExampleQuery from 'accent-webapp/queries/jipt-example';
import ApolloSubscription, {
  Subscription
} from 'accent-webapp/services/apollo-subscription';

export default class JIPTExampleRoute extends Route {
  @service('apollo-subscription')
  apolloSubscription: ApolloSubscription;

  subscription: Subscription;

  model(params: any) {
    (window as any).accentJiptInit = {
      h: window.location.origin,
      i: params.projectId
    };

    this.subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      jiptExampleQuery,
      {
        props: (data) => ({
          project: data.viewer.project
        }),
        options: {
          variables: {
            projectId: params.projectId
          }
        }
      }
    );

    return this.subscription.currentResult();
  }

  deactivate() {
    this.apolloSubscription.clearSubscription(this.subscription);
  }
}
