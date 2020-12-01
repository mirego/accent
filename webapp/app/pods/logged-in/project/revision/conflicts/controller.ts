import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {readOnly, equal, empty, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import translationCorrectQuery from 'accent-webapp/queries/correct-translation';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import Apollo from 'accent-webapp/services/apollo';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';
import projectTranslateTextQuery from 'accent-webapp/queries/translate-text-project';

const FLASH_MESSAGE_CORRECT_SUCCESS =
  'pods.project.conflicts.flash_messages.correct_success';
const FLASH_MESSAGE_CORRECT_ERROR =
  'pods.project.conflicts.flash_messages.correct_error';

export default class ConflictsController extends Controller {
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

  queryParams = ['page', 'query', 'document'];

  @tracked
  query = '';

  @tracked
  document: string | null = null;

  @tracked
  page = 1;

  @readOnly('globalState.permissions')
  permissions: any;

  @equal('model.translations.entries', undefined)
  emptyEntries: boolean;

  @empty('document')
  emptyDocument: boolean;

  @equal('query', '')
  emptyQuery: boolean;

  @and('emptyEntries', 'model.loading')
  showLoading: boolean;

  @and('emptyEntries', 'model.loading', 'emptyQuery', 'emptyDocument')
  showSkeleton: boolean;

  @action
  async copyTranslation(
    text: string,
    sourceLanguageSlug: string,
    targetLanguageSlug: string
  ) {
    const {data} = await this.apollo.client.query({
      fetchPolicy: 'network-only',
      query: projectTranslateTextQuery,
      variables: {
        text,
        sourceLanguageSlug,
        targetLanguageSlug,
        projectId: this.model.project.id,
      },
    });

    if (data.viewer?.project?.translatedText?.[0]) {
      return data.viewer.project.translatedText[0];
    } else {
      return {text: null};
    }
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
  selectPage(page: number) {
    window.scrollTo(0, 0);

    this.page = page;
  }
}
