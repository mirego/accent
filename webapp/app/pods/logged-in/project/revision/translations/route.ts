import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';

import translationsQuery from 'accent-webapp/queries/translations';
import ApolloSubscription, {
  Subscription,
} from 'accent-webapp/services/apollo-subscription';
import RouteParams from 'accent-webapp/services/route-params';
import TranslationsController from 'accent-webapp/pods/logged-in/project/revision/translations/controller';
import RouterService from '@ember/routing/router-service';
import Transition from '@ember/routing/-private/transition';

export default class TranslationsRoute extends Route {
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
  };

  subscription: Subscription;

  model(params: any, transition: Transition) {
    params.isTextEmpty = params.isTextEmpty === 'true' ? true : null;
    params.isTextNotEmpty = params.isTextNotEmpty === 'true' ? true : null;
    params.isAddedLastSync = params.isAddedLastSync === 'true' ? true : null;
    params.isCommentedOn = params.isCommentedOn === 'true' ? true : null;

    this.subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      translationsQuery,
      {
        props: (data) => ({
          revisionId: this.routeParams.fetch(
            transition,
            'logged-in.project.revision'
          ).revisionId,
          project: data.viewer.project,
          documents: data.viewer.project.documents.entries,
          versions: data.viewer.project.versions.entries,
          translations: data.viewer.project.revision.translations,
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
            ...params,
          },
        },
      }
    );

    return this.subscription.currentResult();
  }

  resetController(controller: TranslationsController, isExiting: boolean) {
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
  onRevisionChange({revisionId}: {revisionId: string}) {
    const {project} = this.modelFor('logged-in.project') as {project: any};

    this.router.transitionTo(
      'logged-in.project.revision.translations',
      project.id,
      revisionId
    );
  }
}
