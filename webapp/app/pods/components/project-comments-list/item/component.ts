import Component from '@glimmer/component';

import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';

interface Args {
  groupedComment: any;
  project: any;
}

export default class ProjectCommentsListItem extends Component<Args> {
  translationKey = parsedKeyProperty(this.args.groupedComment.value.key);
}
