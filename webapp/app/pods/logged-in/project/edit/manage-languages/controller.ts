import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';

import revisionCreateQuery from 'accent-webapp/queries/create-revision';
import revisionDeleteQuery from 'accent-webapp/queries/delete-revision';
import revisionMasterPromoteQuery from 'accent-webapp/queries/promote-master-revision';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import IntlService from 'ember-intl/services/intl';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';
import RouterService from '@ember/routing/router-service';

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

export default class ManageLanguagesController extends Controller {
  @service('flash-messages')
  flashMessages: FlashMessages;

  @service('intl')
  intl: IntlService;

  @service('router')
  router: RouterService;

  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('global-state')
  globalState: GlobalState;

  @readOnly('globalState.permissions')
  permissions: any;

  @equal('model.languages', undefined)
  emptyLanguages: boolean;

  @and('emptyLanguages', 'model.loading')
  showLoading: boolean;

  @tracked
  errors = [];

  get filteredLanguages() {
    const projectLanguages = this.model.project.revisions.map(
      (revision: any) => revision.language.id
    );

    return this.model.languages.filter(
      ({id}: {id: string}) => !projectLanguages.includes(id)
    );
  }

  @action
  async deleteRevision(revision: any) {
    try {
      await this.apolloMutate.mutate({
        mutation: revisionDeleteQuery,
        variables: {
          revisionId: revision.id,
        },
      });

      this.flashMessages.success(
        this.intl.t(FLASH_MESSAGE_REVISION_DELETED_SUCCESS)
      );

      this.send('onRefresh');
    } catch (error) {
      this.flashMessages.error(
        this.intl.t(FLASH_MESSAGE_REVISION_DELETED_ERROR)
      );
    }
  }

  @action
  async promoteRevisionMaster(revision: any) {
    try {
      await this.apolloMutate.mutate({
        mutation: revisionMasterPromoteQuery,
        variables: {
          revisionId: revision.id,
        },
      });

      this.flashMessages.success(
        this.intl.t(FLASH_MESSAGE_REVISION_MASTER_PROMOTED_SUCCESS)
      );

      this.send('onRefresh');
    } catch (error) {
      this.flashMessages.error(
        this.intl.t(FLASH_MESSAGE_REVISION_MASTER_PROMOTED_ERROR)
      );
    }
  }

  @action
  async create(languageId: string) {
    const project = this.model.project;
    this.errors = [];

    try {
      await this.apolloMutate.mutate({
        mutation: revisionCreateQuery,
        refetchQueries: ['Dashboard', 'Project'],
        variables: {
          projectId: project.id,
          languageId,
        },
      });

      this.flashMessages.success(
        this.intl.t(FLASH_MESSAGE_NEW_LANGUAGE_SUCCESS)
      );

      this.router.transitionTo('logged-in.project.index', project.id);
    } catch (error) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_NEW_LANGUAGE_FAILURE));
    }
  }
}
