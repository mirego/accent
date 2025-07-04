import {service} from '@ember/service';
import {action} from '@ember/object';
import {equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import {tracked} from '@glimmer/tracking';
import IntlService from 'ember-intl/services/intl';

import commentDeleteQuery from 'accent-webapp/queries/delete-comment';
import commentUpdateQuery from 'accent-webapp/queries/update-comment';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import FlashMessages from 'ember-cli-flash/services/flash-messages';

const FLASH_MESSAGE_PREFIX = 'pods.project.comments.flash_messages.';
const FLASH_MESSAGE_DELETE_COMMENT_SUCCESS = `${FLASH_MESSAGE_PREFIX}delete_success`;
const FLASH_MESSAGE_DELETE_COMMENT_ERROR = `${FLASH_MESSAGE_PREFIX}delete_error`;

export default class CommentsController extends Controller {
  queryParams = ['page'];

  @service('apollo-mutate')
  declare apolloMutate: ApolloMutate;

  @service('flash-messages')
  declare flashMessages: FlashMessages;

  @service('intl')
  declare intl: IntlService;

  @tracked
  page: number | null = 1;

  @equal('model.comments.entries', undefined)
  emptyEntries: boolean;

  @and('emptyEntries', 'model.loading')
  showSkeleton: boolean;

  @action
  selectPage(page: number) {
    window.scroll(0, 0);

    this.page = page;
  }

  @action
  async updateComment(comment: {id: string; text: string}) {
    return this.apolloMutate.mutate({
      mutation: commentUpdateQuery,
      refetchQueries: ['ProjectComments'],
      variables: {
        commentId: comment.id,
        text: comment.text
      }
    });
  }

  @action
  async deleteComment(comment: {id: string}) {
    const response = await this.apolloMutate.mutate({
      mutation: commentDeleteQuery,
      refetchQueries: ['ProjectComments'],
      variables: {
        commentId: comment.id
      }
    });

    if (response.errors) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_DELETE_COMMENT_ERROR));
    } else {
      this.flashMessages.success(
        this.intl.t(FLASH_MESSAGE_DELETE_COMMENT_SUCCESS)
      );
    }
  }
}
