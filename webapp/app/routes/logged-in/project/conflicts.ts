import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';

import translationsQuery from 'accent-webapp/queries/conflicts';
import ApolloSubscription, {
  Subscription,
} from 'accent-webapp/services/apollo-subscription';
import RouteParams from 'accent-webapp/services/route-params';
import Transition from '@ember/routing/transition';
import ConflictsController from 'accent-webapp/controllers/logged-in/project/conflicts';
import RouterService from '@ember/routing/router-service';

export default class ConflictsRoute extends Route {
  @service('apollo-subscription')
  apolloSubscription: ApolloSubscription;

  @service('route-params')
  routeParams: RouteParams;

  @service('router')
  router: RouterService;

  queryParams = {
    query: {
      refreshModel: true,
    },
    page: {
      refreshModel: true,
    },
    document: {
      refreshModel: true,
    },
    version: {
      refreshModel: true,
    },
    relatedRevisions: {
      refreshModel: true,
    },
    isTextEmpty: {
      refreshModel: true,
    },
    isTextNotEmpty: {
      refreshModel: true,
    },
    isAddedLastSync: {
      refreshModel: true,
    },
    isCommentedOn: {
      refreshModel: true,
    },
    isConflicted: {
      refreshModel: true,
    },
    isTranslated: {
      refreshModel: true,
    },
  };

  subscription: Subscription;

  model(params: any, transition: Transition) {
    params.isTextEmpty = params.isTextEmpty === 'true' ? true : null;
    params.isTextNotEmpty = params.isTextNotEmpty === 'true' ? true : null;
    params.isAddedLastSync = params.isAddedLastSync === 'true' ? true : null;
    params.isCommentedOn = params.isCommentedOn === 'true' ? true : null;
    params.isTranslated = params.isTranslated === 'true' ? false : null;

    this.subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      translationsQuery,
      {
        props: (data) => ({
          projectModel: this.modelFor('logged-in.project'),
          prompts: data.viewer.project.prompts,
          documents: data.viewer.project.documents.entries,
          versions: data.viewer.project.versions.entries,
          revisions: data.viewer.project.revisions,
          relatedRevisions: data.viewer.project.groupedTranslations.revisions,
          project: data.viewer.project,
          groupedTranslations: data.viewer.project.groupedTranslations,
        }),
        options: {
          fetchPolicy: 'cache-and-network',
          variables: {
            projectId: this.routeParams.fetch(transition, 'logged-in.project')
              .projectId,
            ...params,
          },
        },
      }
    );

    return this.subscription.currentResult();
  }

  resetController(controller: ConflictsController, isExiting: boolean) {
    if (isExiting) {
      controller.page = 1;
    }
  }

  activate() {
    window.scrollTo(0, 0);
  }

  deactivate() {
    this.apolloSubscription.clearSubscription(this.subscription);
  }

  @action
  onRefresh() {
    this.refresh();
  }
}
