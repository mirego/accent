import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';

import commentCreateQuery from 'accent-webapp/queries/create-comment';
import translationCommentsSubscriptionCreateQuery from 'accent-webapp/queries/create-translation-comments-subscription';
import translationCommentsSubscriptionDeleteQuery from 'accent-webapp/queries/delete-translation-comments-subscription';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';

export default class CommentsController extends Controller {
  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('global-state')
  globalState: GlobalState;

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
