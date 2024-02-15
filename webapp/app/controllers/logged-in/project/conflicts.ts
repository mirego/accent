import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {readOnly, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import translationCorrectQuery from 'accent-webapp/queries/correct-translation';
import translationUncorrectQuery from 'accent-webapp/queries/uncorrect-translation';
import translationUpdateQuery from 'accent-webapp/queries/update-translation';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import Apollo from 'accent-webapp/services/apollo';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';

const FLASH_MESSAGE_CORRECT_SUCCESS =
  'pods.project.conflicts.flash_messages.correct_success';
const FLASH_MESSAGE_CORRECT_ERROR =
  'pods.project.conflicts.flash_messages.correct_error';
const FLASH_MESSAGE_UNCORRECT_SUCCESS =
  'pods.project.conflicts.flash_messages.uncorrect_success';
const FLASH_MESSAGE_UNCORRECT_ERROR =
  'pods.project.conflicts.flash_messages.uncorrect_error';
const FLASH_MESSAGE_UPDATE_SUCCESS =
  'pods.project.conflicts.flash_messages.update_success';
const FLASH_MESSAGE_UPDATE_ERROR =
  'pods.project.conflicts.flash_messages.update_error';

export default class ConflictsController extends Controller {
  @tracked
  model: any;

  @service('intl')
  intl: IntlService;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @service('apollo')
  apollo: Apollo;

  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('global-state')
  globalState: GlobalState;

  queryParams = [
    'page',
    'query',
    'document',
    'version',
    'relatedRevisions',
    'isTextEmpty',
    'isTextNotEmpty',
    'isAddedLastSync',
    'isCommentedOn',
    'isTranslatedFilter',
  ];

  @tracked
  query = '';

  @tracked
  document: string | null = null;

  @tracked
  version: string | null = null;

  @tracked
  relatedRevisions: string[] = [];

  @tracked
  isTextEmpty: 'true' | null = null;

  @tracked
  isTextNotEmpty: 'true' | null = null;

  @tracked
  isAddedLastSync: 'true' | null = null;

  @tracked
  isTranslated: 'true' | null = null;

  @tracked
  isCommentedOn: 'true' | null = null;

  @tracked
  page = 1;

  @readOnly('globalState.permissions')
  permissions: any;

  @equal('model.groupedTranslations.entries', undefined)
  emptyEntries: boolean;

  @and('emptyEntries', 'model.loading')
  showLoading: boolean;

  @and('emptyEntries', 'model.loading')
  showSkeleton: boolean;

  get withAdvancedFilters() {
    return [
      this.isTextEmpty,
      this.isTextNotEmpty,
      this.isAddedLastSync,
      this.isCommentedOn,
      this.isTranslated,
    ].filter((filter) => filter === 'true').length;
  }

  @action
  changeAdvancedFilterBoolean(
    key:
      | 'isTextEmpty'
      | 'isTextNotEmpty'
      | 'isAddedLastSync'
      | 'isCommentedOn'
      | 'isTranslated',
    event: InputEvent
  ) {
    this[key] = (event.target as HTMLInputElement).checked ? 'true' : null;
  }

  @action
  async correctConflict(conflict: any, text: string) {
    const response = await this.apolloMutate.mutate({
      mutation: translationCorrectQuery,
      variables: {
        translationId: conflict.id,
        text,
      },
    });

    if (response.errors) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_CORRECT_ERROR));
    } else {
      this.flashMessages.success(this.intl.t(FLASH_MESSAGE_CORRECT_SUCCESS));
    }

    return response;
  }

  @action
  async uncorrectConflict(conflict: any, text: string) {
    const response = await this.apolloMutate.mutate({
      mutation: translationUncorrectQuery,
      variables: {
        translationId: conflict.id,
        text,
      },
    });

    if (response.errors) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_UNCORRECT_ERROR));
    } else {
      this.flashMessages.success(this.intl.t(FLASH_MESSAGE_UNCORRECT_SUCCESS));
    }

    return response;
  }

  @action
  async updateConflict(conflict: any, text: string) {
    const response = await this.apolloMutate.mutate({
      mutation: translationUpdateQuery,
      variables: {
        translationId: conflict.id,
        text,
      },
    });

    if (response.errors) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_UPDATE_ERROR));
    } else {
      this.flashMessages.success(this.intl.t(FLASH_MESSAGE_UPDATE_SUCCESS));
    }

    return response;
  }

  @action
  changeQuery(query: string) {
    this.page = 1;
    this.query = query;
  }

  @action
  changeDocument(select: HTMLSelectElement) {
    this.page = 1;
    this.document = select.value ? select.value : null;
  }

  @action
  changeVersion(select: HTMLSelectElement) {
    this.page = 1;
    this.version = select.value ? select.value : null;
  }

  @action
  changeRelatedRevisions(choices: Array<{value: string}>) {
    this.page = 1;
    this.relatedRevisions = choices.map(({value}) => value);
  }

  @action
  selectPage(page: number) {
    window.scrollTo(0, 0);

    this.page = page;
  }
}
