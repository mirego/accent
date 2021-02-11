import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import IntlService from 'ember-intl/services/intl';

import commentCreateQuery from 'accent-webapp/queries/create-comment';
import commentDeleteQuery from 'accent-webapp/queries/delete-comment';
import commentUpdateQuery from 'accent-webapp/queries/update-comment';
import translationCommentsSubscriptionCreateQuery from 'accent-webapp/queries/create-translation-comments-subscription';
import translationCommentsSubscriptionDeleteQuery from 'accent-webapp/queries/delete-translation-comments-subscription';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';

const FLASH_MESSAGE_PREFIX = 'pods.translation.comments.flash_messages.';
const FLASH_MESSAGE_DELETE_COMMENT_SUCCESS = `${FLASH_MESSAGE_PREFIX}delete_success`;
const FLASH_MESSAGE_DELETE_COMMENT_ERROR = `${FLASH_MESSAGE_PREFIX}delete_error`;

export default class CommentsController extends Controller {
  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @service('global-state')
  globalState: GlobalState;

  @service('intl')
  intl: IntlService;

  queryParams = ['page'];

  @tracked
  page: number | null = null;

  @readOnly('globalState.permissions')
  permissions: any;

  @equal('model.comments', undefined)
  emptyEntries: boolean;

  @and('emptyEntries', 'model.loading')
  showSkeleton: boolean;

  @action
  async createComment(text: string) {
    if (!text) text = '';
    const translation = this.model.translation;

    return this.apolloMutate.mutate({
      mutation: commentCreateQuery,
      refetchQueries: ['TranslationComments'],
      variables: {
        translationId: translation.id,
        text,
      },
    });
  }

  @action
  async updateComment(comment: {id: string; text: string}) {
    return this.apolloMutate.mutate({
      mutation: commentUpdateQuery,
      refetchQueries: ['TranslationComments'],
      variables: {
        commentId: comment.id,
        text: comment.text,
      },
    });
  }

  @action
  async deleteComment(comment: {id: string}) {
    const response = await this.apolloMutate.mutate({
      mutation: commentDeleteQuery,
      refetchQueries: ['TranslationComments'],
      variables: {
        commentId: comment.id,
      },
    });

    if (response.errors) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_DELETE_COMMENT_ERROR));
    } else {
      this.flashMessages.success(
        this.intl.t(FLASH_MESSAGE_DELETE_COMMENT_SUCCESS)
      );
    }
  }

  @action
  async createSubscription(user: any) {
    const translation = this.model.translation;

    return this.apolloMutate.mutate({
      mutation: translationCommentsSubscriptionCreateQuery,
      refetchQueries: ['TranslationComments'],
      variables: {
        translationId: translation.id,
        userId: user.id,
      },
    });
  }

  @action
  async deleteSubscription(subscription: any) {
    return this.apolloMutate.mutate({
      mutation: translationCommentsSubscriptionDeleteQuery,
      refetchQueries: ['TranslationComments'],
      variables: {
        translationCommentsSubscripitionId: subscription.id,
      },
    });
  }

  @action
  selectPage(page: number) {
    window.scroll(0, 0);

    this.page = page;
  }
}
