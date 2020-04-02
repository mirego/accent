import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import translationUpdateQuery from 'accent-webapp/queries/update-translation';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import GlobalState from 'accent-webapp/services/global-state';
import IntlService from 'ember-intl/services/intl';
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
  isCommentedOn: 'true' | null = null;

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
    ].filter((filter) => filter === 'true').length;
  }

  @action
  changeQuery(query: string) {
    this.page = 1;
    this.query = query;
  }

  @action
  changeAdvancedFilterBoolean(
    key: 'isTextEmpty' | 'isTextNotEmpty' | 'isAddedLastSync' | 'isCommentedOn',
    event: InputEvent
  ) {
    this[key] = (event.target as HTMLInputElement).checked ? 'true' : null;
  }

  @action
  changeVersion(versionId: string) {
    this.page = 1;
    this.version = versionId;
  }

  @action
  changeDocument(documentId: string) {
    this.page = 1;
    this.document = documentId;
  }

  @action
  selectPage(page: number) {
    window.scrollTo(0, 0);

    this.page = page;
  }

  @action
  async updateText(translation: any, text: string) {
    try {
      await this.apolloMutate.mutate({
        mutation: translationUpdateQuery,
        variables: {
          translationId: translation.id,
          text,
        },
      });
      this.flashMessages.success(this.intl.t(FLASH_MESSAGE_UPDATE_SUCCESS));
    } catch (error) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_UPDATE_ERROR));
    }
  }
}
