import {action} from '@ember/object';
import {readOnly} from '@ember/object/computed';
import {inject as service} from '@ember/service';
import Controller from '@ember/controller';

import revisionUpdateQuery from 'accent-webapp/queries/update-revision';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import Session from 'accent-webapp/services/session';
import {tracked} from '@glimmer/tracking';
import RouterService from '@ember/routing/router-service';

export default class ManageLanguagesEditController extends Controller {
  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('session')
  session: Session;

  @service('router')
  router: RouterService;

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
      'logged-in.project.edit.manage-languages',
      this.project.id
    );
  }

  @action
  async update(revisionAttributes: any) {
    this.error = false;

    try {
      await this.apolloMutate.mutate({
        mutation: revisionUpdateQuery,
        variables: {
          revisionId: this.revision.id,
          ...revisionAttributes,
        },
      });

      this.router.transitionTo(
        'logged-in.project.edit.manage-languages',
        this.project.id
      );
    } catch (error) {
      this.error = true;
    }
  }
}
