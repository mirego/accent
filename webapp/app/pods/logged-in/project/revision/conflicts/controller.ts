import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {readOnly, equal, empty, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import translationCorrectQuery from 'accent-webapp/queries/correct-translation';
import correctAllRevisionQuery from 'accent-webapp/queries/correct-all-revision';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';

const FLASH_MESSAGE_REVISION_CORRECT_SUCCESS =
  'pods.project.conflicts.flash_messages.revision_correct_success';
const FLASH_MESSAGE_REVISION_CORRECT_ERROR =
  'pods.project.conflicts.flash_messages.revision_correct_error';
const FLASH_MESSAGE_CORRECT_SUCCESS =
  'pods.project.conflicts.flash_messages.correct_success';
const FLASH_MESSAGE_CORRECT_ERROR =
  'pods.project.conflicts.flash_messages.correct_error';

export default class ConflictsController extends Controller {
  @service('intl')
  intl: IntlService;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('global-state')
  globalState: GlobalState;

  queryParams = ['reference', 'page', 'query', 'document'];

  @tracked
  fullscreen = false;

  @tracked
  query = '';

  @tracked
  reference = null;

  @tracked
  document = null;

  @tracked
  page = 1;

  @readOnly('globalState.permissions')
  permissions: any;

  @readOnly('model.project.revision')
  revision: any;

  @readOnly('model.revisionModel.project.revisions')
  revisions: any;

  @equal('model.translations.entries', undefined)
  emptyEntries: boolean;

  @empty('reference')
  emptyReference: boolean;

  @empty('document')
  emptyDocument: boolean;

  @equal('query', '')
  emptyQuery: boolean;

  @and('emptyEntries', 'model.loading')
  showLoading: boolean;

  @and(
    'emptyEntries',
    'model.loading',
    'emptyQuery',
    'emptyReference',
    'emptyDocument'
  )
  showSkeleton: boolean;

  get referenceRevisions() {
    if (!this.revisions) return [];

    return this.revisions.filter((revision: any) => {
      return revision.id !== this.model.revisionId;
    });
  }

  get referenceRevision() {
    if (!this.revisions || !this.model.referenceRevisionId) return;

    return this.revisions.find((revision: any) => {
      return revision.id === this.model.referenceRevisionId;
    });
  }

  @action
  deactivateFullscreen() {
    this.fullscreen = false;
  }

  @action
  async correctConflict(conflict: any, text: string) {
    try {
      await this.apolloMutate.mutate({
        mutation: translationCorrectQuery,
        variables: {
          translationId: conflict.id,
          text,
        },
      });

      this.flashMessages.success(this.intl.t(FLASH_MESSAGE_CORRECT_SUCCESS));
    } catch (error) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_CORRECT_ERROR));
    }
  }

  @action
  async correctAllConflicts() {
    try {
      await this.apolloMutate.mutate({
        mutation: correctAllRevisionQuery,
        variables: {revisionId: this.revision.id},
      });

      this.flashMessages.success(
        this.intl.t(FLASH_MESSAGE_REVISION_CORRECT_SUCCESS)
      );

      return this.send('onRefresh');
    } catch (error) {
      this.flashMessages.error(
        this.intl.t(FLASH_MESSAGE_REVISION_CORRECT_ERROR)
      );
    }
  }

  @action
  changeQuery(query: string) {
    this.page = 1;
    this.query = query;
  }

  @action
  changeReference(reference: any) {
    this.reference = reference.value;
  }

  @action
  changeDocument(documentEntry: any) {
    this.page = 1;
    this.document = documentEntry.value;
  }

  @action
  selectPage(page: number) {
    window.scrollTo(0, 0);

    this.page = page;
  }
}
