import Component from '@glimmer/component';

import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';

interface Args {
  groupedComment: any;
  project: any;
  onUpdateComment: (comment: {id: string; text: string}) => Promise<void>;
  onDeleteComment: (comment: {id: string}) => Promise<void>;
}

export default class ProjectCommentsListItem extends Component<Args> {
  translationKey = parsedKeyProperty(this.args.groupedComment.value.key);
}
