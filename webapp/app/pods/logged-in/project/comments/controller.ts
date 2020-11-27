import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';
import {tracked} from '@glimmer/tracking';
import IntlService from 'ember-intl/services/intl';

import commentDeleteQuery from 'accent-webapp/queries/delete-comment';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import FlashMessages from 'ember-cli-flash/services/flash-messages';

const FLASH_MESSAGE_PREFIX = 'pods.project.comments.flash_messages.';
const FLASH_MESSAGE_DELETE_COMMENT_SUCCESS = `${FLASH_MESSAGE_PREFIX}delete_success`;
const FLASH_MESSAGE_DELETE_COMMENT_ERROR = `${FLASH_MESSAGE_PREFIX}delete_error`;

export default class CommentsController extends Controller {
  queryParams = ['page'];

  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @service('intl')
  intl: IntlService;

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
  async deleteComment(comment: {id: string}) {
    try {
      await this.apolloMutate.mutate({
        mutation: commentDeleteQuery,
        refetchQueries: ['ProjectComments'],
        variables: {
          commentId: comment.id,
        },
      });

      this.flashMessages.success(
        this.intl.t(FLASH_MESSAGE_DELETE_COMMENT_SUCCESS)
      );
    } catch (error) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_DELETE_COMMENT_ERROR));
    }
  }
}
