import Component from '@glimmer/component';

interface Args {
  project: any;
  comments: any;
  onUpdateComment: (comment: {id: string; text: string}) => Promise<void>;
  onDeleteComment: (comment: {id: string}) => Promise<void>;
}

export default class ProjectCommentsList extends Component<Args> {
  get translationsById() {
    return this.args.comments
      .map((comment: any) => comment.translation)
      .reduce((memo: Record<string, any>, translation: any) => {
        if (!memo[translation.id]) memo[translation.id] = translation;

        return memo;
      }, {});
  }

  get commentsByTranslationId() {
    return this.args.comments.reduce(
      (memo: Record<string, any[]>, comment: any) => {
        memo[comment.translation.id] = memo[comment.translation.id] || [];
        memo[comment.translation.id].push(comment);

        return memo;
      },
      {}
    );
  }

  get commentsByTranslation() {
    return Object.keys(this.commentsByTranslationId).map((translationId) => {
      return {
        items: this.commentsByTranslationId[translationId],
        value: this.translationsById[translationId]
      };
    });
  }
}
