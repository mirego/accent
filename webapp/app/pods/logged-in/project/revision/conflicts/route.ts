import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';

import translationsQuery from 'accent-webapp/queries/conflicts';
import ApolloSubscription, {
  Subscription,
} from 'accent-webapp/services/apollo-subscription';
import RouteParams from 'accent-webapp/services/route-params';
import Transition from '@ember/routing/-private/transition';
import ConflictsController from 'accent-webapp/pods/logged-in/project/revision/conflicts/controller';
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
  };

  subscription: Subscription;

  model(
    {
      query,
      page,
      document,
      version,
    }: {query: any; page: number; document: any; version: any},
    transition: Transition
  ) {
    this.subscription = this.apolloSubscription.graphql(
      () => this.modelFor(this.routeName),
      translationsQuery,
      {
        props: (data) => ({
          revisionModel: this.modelFor('logged-in.project.revision'),
          documents: data.viewer.project.documents.entries,
          versions: data.viewer.project.versions.entries,
          prompts: data.viewer.project.prompts,
          project: data.viewer.project,
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
            query,
            page,
            document,
            version,
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

  @action
  onRevisionChange({revisionId}: {revisionId: string}) {
    const {project} = this.modelFor('logged-in.project') as {project: any};

    this.apolloSubscription.clearSubscription(this.subscription);

    this.router.transitionTo(
      'logged-in.project.revision.conflicts',
      project.id,
      revisionId,
      {
        queryParams: this.fetchQueryParams(
          this.controller as ConflictsController
        ),
      }
    );
  }

  private fetchQueryParams(controller: ConflictsController) {
    const query = controller.query;

    return {
      query,
    };
  }
}
