import {inject as service} from '@ember/service';
import {readOnly, equal, and} from '@ember/object/computed';
import {action} from '@ember/object';
import Controller from '@ember/controller';
import correctAllRevisionQuery from 'accent-webapp/queries/correct-all-revision';
import uncorrectAllRevisionQuery from 'accent-webapp/queries/uncorrect-all-revision';
import GlobalState from 'accent-webapp/services/global-state';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import IntlService from 'ember-intl/services/intl';
import {tracked} from '@glimmer/tracking';

const FLASH_MESSAGE_REVISION_CORRECT_SUCCESS =
  'pods.project.index.flash_messages.revision_correct_success';
const FLASH_MESSAGE_REVISION_CORRECT_ERROR =
  'pods.project.index.flash_messages.revision_correct_error';
const FLASH_MESSAGE_REVISION_UNCORRECT_SUCCESS =
  'pods.project.index.flash_messages.revision_uncorrect_success';
const FLASH_MESSAGE_REVISION_UNCORRECT_ERROR =
  'pods.project.index.flash_messages.revision_uncorrect_error';

export default class ProjectIndexController extends Controller {
  @tracked
  model: any;

  @service('global-state')
  globalState: GlobalState;

  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @service('intl')
  intl: IntlService;

  @readOnly('globalState.permissions')
  permissions: any;

  @readOnly('model.project')
  project: any;

  @readOnly('project.revisions')
  revisions: any;

  @equal('model.project', undefined)
  emptyProject: boolean;

  @and('emptyProject', 'model.loading')
  showLoading: boolean;

  get document() {
    return this.project.documents.entries[0];
  }

  @action
  async correctAllConflicts(revision: any) {
    const response = await this.apolloMutate.mutate({
      mutation: correctAllRevisionQuery,
      variables: {revisionId: revision.id},
    });

    if (response.errors) {
      this.flashMessages.error(
        this.intl.t(FLASH_MESSAGE_REVISION_CORRECT_ERROR)
      );
    } else {
      this.flashMessages.success(
        this.intl.t(FLASH_MESSAGE_REVISION_CORRECT_SUCCESS)
      );
    }
  }

  @action
  async uncorrectAllConflicts(revision: any) {
    const response = await this.apolloMutate.mutate({
      mutation: uncorrectAllRevisionQuery,
      variables: {revisionId: revision.id},
    });

    if (response.errors) {
      this.flashMessages.error(
        this.intl.t(FLASH_MESSAGE_REVISION_UNCORRECT_ERROR)
      );
    } else {
      this.flashMessages.success(
        this.intl.t(FLASH_MESSAGE_REVISION_UNCORRECT_SUCCESS)
      );
    }
  }
}
