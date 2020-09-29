import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {readOnly, equal, empty, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import translationCorrectQuery from 'accent-webapp/queries/correct-translation';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';

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
