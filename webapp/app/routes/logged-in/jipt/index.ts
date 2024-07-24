import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';

import translationsQuery from 'accent-webapp/queries/jipt-translations';
import ApolloSubscription, {
  Subscription
} from 'accent-webapp/services/apollo-subscription';
import RouteParams from 'accent-webapp/services/route-params';
import Transition from '@ember/routing/transition';
import IndexController from 'accent-webapp/controllers/logged-in/jipt/index';

export default class IndexRoute extends Route {
  @service('apollo-subscription')
  apolloSubscription: ApolloSubscription;

  @service('route-params')
  routeParams: RouteParams;

  queryParams = {
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
  };

  subscription: Subscription;

  model(
    {
      query,
      page,
      document,
      version
    }: {query: any; page: number; document: any; version: any},
    transition: Transition
  ) {
    if (this.subscription)
      this.apolloSubscription.clearSubscription(this.subscription);

    const projectId = this.routeParams.fetch(
      transition,
      'logged-in.jipt'
    ).projectId;

    this.subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      translationsQuery,
      {
        props: (data) => ({
          project: data.viewer.project,
          documents: data.viewer.project.documents.entries,
          versions: data.viewer.project.versions.entries,
          translations: data.viewer.project.revision.translations,
          selectedTranslationIds: transition?.to?.queryParams.translationIds
        }),
        options: {
          fetchPolicy: 'cache-and-network',
          variables: {
            projectId,
            revisionId: transition?.to?.queryParams.revisionId,
            query,
            page,
            document,
            version
          }
        }
      }
    );

    return this.subscription.currentResult();
  }

  activate() {
    window.scrollTo(0, 0);
  }

  deactivate() {
    this.apolloSubscription.clearSubscription(this.subscription);
  }

  resetController(controller: IndexController, isExiting: boolean) {
    if (isExiting) {
      controller.page = 1;
    }
  }
}
