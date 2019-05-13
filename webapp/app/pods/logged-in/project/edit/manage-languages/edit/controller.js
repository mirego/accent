import {computed} from '@ember/object';
import {alias} from '@ember/object/computed';
import {inject as service} from '@ember/service';
import Controller from '@ember/controller';

import revisionUpdateQuery from 'accent-webapp/queries/update-revision';

export default Controller.extend({
  apolloMutate: service('apollo-mutate'),
  session: service(),

  error: false,

  project: alias('model.revisionsModel.project'),
  revision: computed(
    'model.{revisionsModel.project.revisions,revisionId}',
    function() {
      if (!this.model.revisionsModel.project) return;

      return this.model.revisionsModel.project.revisions.find(
        revision => revision.id === this.model.revisionId
      );
    }
  ),

  actions: {
    closeModal() {
      this.transitionToRoute(
        'logged-in.project.edit.manage-languages',
        this.project.id
      );
    },

    update(revisionAttributes) {
      this.set('error', false);

      return this.apolloMutate
        .mutate({
          mutation: revisionUpdateQuery,
          variables: {
            revisionId: this.revision.id,
            ...revisionAttributes
          }
        })
        .then(_ =>
          this.transitionToRoute(
            'logged-in.project.edit.manage-languages',
            this.project.id
          )
        )
        .catch(() => this.set('error', true));
    }
  }
});
