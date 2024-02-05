import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {equal, and, readOnly} from '@ember/object/computed';
import Controller from '@ember/controller';
import translationUpdateQuery from 'accent-webapp/queries/update-translation';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import IntlService from 'ember-intl/services/intl';
import GlobalState from 'accent-webapp/services/global-state';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import {tracked} from '@glimmer/tracking';

const FLASH_MESSAGE_UPDATE_SUCCESS =
  'pods.translation.edit.flash_messages.update_success';
const FLASH_MESSAGE_UPDATE_ERROR =
  'pods.translation.edit.flash_messages.update_error';

export default class TranslationsController extends Controller {
  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('global-state')
  globalState: GlobalState;

  @service('intl')
  intl: IntlService;

  @service('flash-messages')
  flashMessages: FlashMessages;

  queryParams = [
    'query',
    'page',
    'document',
    'version',
    'isTextEmpty',
    'isTextNotEmpty',
    'isAddedLastSync',
    'isCommentedOn',
    'isConflictedFilter',
    'isTranslatedFilter',
  ];

  @tracked
  query = '';

  @tracked
  page = 1;

  @tracked
  document: string | null = null;

  @tracked
  version: string | null = null;

  @tracked
  isTextEmpty: 'true' | null = null;

  @tracked
  isTextNotEmpty: 'true' | null = null;

  @tracked
  isAddedLastSync: 'true' | null = null;

  @tracked
  isConflicted: 'true' | null = null;

  @tracked
  isTranslated: 'true' | null = null;

  @tracked
  isCommentedOn: 'true' | null = null;

  @readOnly('globalState.permissions')
  permissions: any;

  @readOnly('model.revisionModel.project.revisions')
  revisions: any;

  @equal('model.translations.entries', undefined)
  emptyEntries: boolean;

  @equal('query', '')
  emptyQuery: boolean;

  @and('emptyEntries', 'model.loading', 'emptyQuery')
  showSkeleton: boolean;

  @and('emptyEntries', 'model.loading')
  showLoading: boolean;

  get withAdvancedFilters() {
    return [
      this.isTextEmpty,
      this.isTextNotEmpty,
      this.isAddedLastSync,
      this.isCommentedOn,
      this.isConflicted,
      this.isTranslated,
    ].filter((filter) => filter === 'true').length;
  }

  @action
  changeQuery(query: string) {
    this.page = 1;
    this.query = query;
  }

  @action
  changeAdvancedFilterBoolean(
    key:
      | 'isTextEmpty'
      | 'isTextNotEmpty'
      | 'isAddedLastSync'
      | 'isCommentedOn'
      | 'isConflicted'
      | 'isTranslated',
    event: InputEvent
  ) {
    this[key] = (event.target as HTMLInputElement).checked ? 'true' : null;
  }

  @action
  changeVersion(select: HTMLSelectElement) {
    this.page = 1;
    this.version = select.value ? select.value : null;
  }

  @action
  changeDocument(select: HTMLSelectElement) {
    this.page = 1;
    this.document = select.value ? select.value : null;
  }

  @action
  selectPage(page: number) {
    window.scrollTo(0, 0);

    this.page = page;
  }

  @action
  async updateText(translation: any, text: string) {
    const response = await this.apolloMutate.mutate({
      mutation: translationUpdateQuery,
      variables: {
        translationId: translation.id,
        text,
      },
    });

    if (response.errors) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_UPDATE_ERROR));
    } else {
      this.flashMessages.success(this.intl.t(FLASH_MESSAGE_UPDATE_SUCCESS));
    }
  }
}
