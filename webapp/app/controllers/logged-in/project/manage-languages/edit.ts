import {action} from '@ember/object';
import {readOnly} from '@ember/object/computed';
import {service} from '@ember/service';
import Controller from '@ember/controller';

import revisionUpdateQuery from 'accent-webapp/queries/update-revision';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import Session from 'accent-webapp/services/session';
import {tracked} from '@glimmer/tracking';
import RouterService from '@ember/routing/router-service';

export default class ManageLanguagesEditController extends Controller {
  @tracked
  model: any;

  @service('apollo-mutate')
  declare apolloMutate: ApolloMutate;

  @service('session')
  declare session: Session;

  @service('router')
  declare router: RouterService;

  @tracked
  error = false;

  @readOnly('model.revisionsModel.project')
  project: any;

  get revision() {
    if (!this.model.revisionsModel.project) return;

    return this.model.revisionsModel.project.revisions.find(
      (revision: any) => revision.id === this.model.revisionId
    );
  }

  @action
  closeModal() {
    this.router.transitionTo(
      'logged-in.project.manage-languages',
      this.project.id
    );
  }

  @action
  async update(revisionAttributes: any) {
    this.error = false;

    const response = await this.apolloMutate.mutate({
      mutation: revisionUpdateQuery,
      variables: {
        revisionId: this.revision.id,
        ...revisionAttributes
      }
    });

    if (response.errors) {
      this.error = true;
    } else {
      this.router.transitionTo(
        'logged-in.project.manage-languages',
        this.project.id
      );
    }
  }
}
