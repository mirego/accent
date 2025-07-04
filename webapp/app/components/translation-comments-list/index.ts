import Component from '@glimmer/component';

interface Args {
  comments: any;
  onDeleteComment: (comment: {id: string}) => Promise<void>;
  onUpdateComment: (comment: {id: string; text: string}) => Promise<void>;
}

export default class TranslationsCommentsList extends Component<Args> {}
