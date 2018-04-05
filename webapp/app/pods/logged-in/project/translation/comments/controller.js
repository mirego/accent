import {inject as service} from '@ember/service';
import {readOnly, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';

import commentCreateQuery from 'accent-webapp/queries/create-comment';
import translationCommentsSubscriptionCreateQuery from 'accent-webapp/queries/create-translation-comments-subscription';
import translationCommentsSubscriptionDeleteQuery from 'accent-webapp/queries/delete-translation-comments-subscription';

export default Controller.extend({
  apolloMutate: service('apollo-mutate'),
  globalState: service('global-state'),

  queryParams: ['page'],

  page: null,

  permissions: readOnly('globalState.permissions'),
  emptyEntries: equal('model.comments', undefined),
  showSkeleton: and('emptyEntries', 'model.loading'),

  actions: {
    createComment(text) {
      if (!text) text = '';
      const translation = this.model.translation;

      return this.apolloMutate.mutate({
        mutation: commentCreateQuery,
        refetchQueries: ['TranslationComments'],
        variables: {
          translationId: translation.id,
          text
        }
      });
    },

    createSubscription(user) {
      const translation = this.model.translation;

      return this.apolloMutate.mutate({
        mutation: translationCommentsSubscriptionCreateQuery,
        refetchQueries: ['TranslationComments'],
        variables: {
          translationId: translation.id,
          userId: user.id
        }
      });
    },

    deleteSubscription(subscription) {
      return this.apolloMutate.mutate({
        mutation: translationCommentsSubscriptionDeleteQuery,
        refetchQueries: ['TranslationComments'],
        variables: {
          translationCommentsSubscripitionId: subscription.id
        }
      });
    },

    selectPage(page) {
      window.scroll(0, 0);
      this.set('page', page);
    }
  }
});
