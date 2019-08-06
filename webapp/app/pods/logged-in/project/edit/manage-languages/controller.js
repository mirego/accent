import {computed} from '@ember/object';
import {inject as service} from '@ember/service';
import {readOnly, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';

import revisionCreateQuery from 'accent-webapp/queries/create-revision';
import revisionDeleteQuery from 'accent-webapp/queries/delete-revision';
import revisionMasterPromoteQuery from 'accent-webapp/queries/promote-master-revision';

const FLASH_MESSAGE_NEW_LANGUAGE_SUCCESS =
  'pods.project.manage_languages.flash_messages.add_revision_success';
const FLASH_MESSAGE_NEW_LANGUAGE_FAILURE =
  'pods.project.manage_languages.flash_messages.add_revision_failure';
const FLASH_MESSAGE_REVISION_DELETED_SUCCESS =
  'pods.project.manage_languages.flash_messages.delete_revision_success';
const FLASH_MESSAGE_REVISION_DELETED_ERROR =
  'pods.project.manage_languages.flash_messages.delete_revision_failure';
const FLASH_MESSAGE_REVISION_MASTER_PROMOTED_SUCCESS =
  'pods.project.manage_languages.flash_messages.promote_master_revision_success';
const FLASH_MESSAGE_REVISION_MASTER_PROMOTED_ERROR =
  'pods.project.manage_languages.flash_messages.promote_master_revision_failure';

export default Controller.extend({
  flashMessages: service(),
  intl: service('intl'),
  apolloMutate: service('apollo-mutate'),
  globalState: service('global-state'),

  permissions: readOnly('globalState.permissions'),
  emptyLanguages: equal('model.languages', undefined),
  showLoading: and('emptyLanguages', 'model.loading'),

  errors: computed(() => []),

  filteredLanguages: computed(
    'model.{languages.[],project.revisions}',
    function() {
      const projectLanguages = this.model.project.revisions.map(
        revision => revision.language.id
      );

      return this.model.languages.filter(
        ({id}) => !projectLanguages.includes(id)
      );
    }
  ),

  actions: {
    deleteRevision(revision) {
      return this.apolloMutate
        .mutate({
          mutation: revisionDeleteQuery,
          variables: {
            revisionId: revision.id
          }
        })
        .then(() => {
          this.flashMessages.success(
            this.intl.t(FLASH_MESSAGE_REVISION_DELETED_SUCCESS)
          );
          this.send('onRefresh');
        })
        .catch(() =>
          this.flashMessages.error(
            this.intl.t(FLASH_MESSAGE_REVISION_DELETED_ERROR)
          )
        );
    },

    promoteRevisionMaster(revision) {
      return this.apolloMutate
        .mutate({
          mutation: revisionMasterPromoteQuery,
          variables: {
            revisionId: revision.id
          }
        })
        .then(() => {
          this.flashMessages.success(
            this.intl.t(FLASH_MESSAGE_REVISION_MASTER_PROMOTED_SUCCESS)
          );
          this.send('onRefresh');
        })
        .catch(() =>
          this.flashMessages.error(
            this.intl.t(FLASH_MESSAGE_REVISION_MASTER_PROMOTED_ERROR)
          )
        );
    },

    create(languageId) {
      const project = this.model.project;
      this.set('errors', []);

      return this.apolloMutate
        .mutate({
          mutation: revisionCreateQuery,
          refetchQueries: ['Dashboard', 'Project'],
          variables: {
            projectId: project.id,
            languageId
          }
        })
        .then(() => {
          this.flashMessages.success(
            this.intl.t(FLASH_MESSAGE_NEW_LANGUAGE_SUCCESS)
          );
          this.transitionToRoute('logged-in.project.index', project.id);
        })
        .catch(() =>
          this.flashMessages.error(
            this.intl.t(FLASH_MESSAGE_NEW_LANGUAGE_FAILURE)
          )
        );
    }
  }
});
