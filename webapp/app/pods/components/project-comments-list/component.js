import {computed} from '@ember/object';
import Component from '@ember/component';

// Attributes:
// project: Object <project>
// comments: Array of <comment>
export default Component.extend({
  tagName: 'ul',

  translationsById: computed('comments', function() {
    return this.comments
      .map(comment => comment.translation)
      .reduce((memo, translation) => {
        if (!memo[translation.id]) memo[translation.id] = translation;

        return memo;
      }, {});
  }),

  commentsByTranslationId: computed('comments', function() {
    return this.comments.reduce((memo, comment) => {
      memo[comment.translation.id] = memo[comment.translation.id] || [];
      memo[comment.translation.id].push(comment);

      return memo;
    }, {});
  }),

  commentsByTranslation: computed(
    'commentsByTranslationId',
    'translationsById',
    function() {
      return Object.keys(this.commentsByTranslationId).map(translationId => {
        return {
          items: this.commentsByTranslationId[translationId],
          value: this.translationsById[translationId]
        };
      });
    }
  )
});
