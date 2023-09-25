import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import Route from '@ember/routing/route';
import GlobalState from 'accent-webapp/services/global-state';

import lintQuery from 'accent-webapp/queries/lint-translations';
import ApolloSubscription, {
  Subscription,
} from 'accent-webapp/services/apollo-subscription';
import RouteParams from 'accent-webapp/services/route-params';
import Transition from '@ember/routing/-private/transition';
import LintTranslationsController from 'accent-webapp/pods/logged-in/project/revision/lint-translations/controller';
import RouterService from '@ember/routing/router-service';

export default class LintRoute extends Route {
  @service('apollo-subscription')
  apolloSubscription: ApolloSubscription;

  @service('route-params')
  routeParams: RouteParams;

  @service('router')
  router: RouterService;

  @service('global-state')
  globalState: GlobalState;

  subscription: Subscription;

  queryParams = {
    documentFilter: {
      refreshModel: true,
    },
    versionFilter: {
      refreshModel: true,
    },
    ruleFilter: {
      refreshModel: true,
    },
    query: {
      refreshModel: true,
    },
  };

  model(params: any, transition: Transition) {
    this.subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      lintQuery,
      {
        props: (data) => ({
          project: data.viewer.project,
          documents: data.viewer.project.documents,
          versions: data.viewer.project.versions,
          lintTranslations: data.viewer.project.lintTranslations,
        }),
        options: {
          fetchPolicy: 'cache-and-network',
          variables: {
            revisionId: this.routeParams.fetch(
              transition,
              'logged-in.project.revision'
            ).revisionId,
            documentId: params.documentFilter,
            versionId: params.versionFilter,
            ruleIds: params.ruleFilter,
            query: params.query,
            projectId: this.routeParams.fetch(transition, 'logged-in.project')
              .projectId,
          },
        },
      }
    );

    return this.subscription.currentResult();
  }

  @action
  onRevisionChange({revisionId}: {revisionId: string}) {
    const {project} = this.modelFor('logged-in.project') as {project: any};

    this.apolloSubscription.clearSubscription(this.subscription);

    this.router.transitionTo(
      'logged-in.project.revision.lint-translations',
      project.id,
      revisionId,
      {
        queryParams: this.fetchQueryParams(
          this.controller as LintTranslationsController
        ),
      }
    );
  }

  private fetchQueryParams(controller: LintTranslationsController) {
    const query = controller.query;

    return {
      query,
    };
  }
}
