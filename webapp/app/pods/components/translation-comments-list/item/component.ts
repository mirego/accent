import {inject as service} from '@ember/service';
import {readOnly} from '@ember/object/computed';
import Component from '@glimmer/component';
import MarkdownIt from 'markdown-it';
import {htmlSafe} from '@ember/string';
import Session from 'accent-webapp/services/session';
import {dropTask} from 'ember-concurrency-decorators';

const markdown = MarkdownIt({
  html: false,
  linkify: true,
  typographer: true,
});

interface Args {
  comment: {
    id: string;
    text: string;
    insertedAt: Date;
    user: {
      id: string;
      fullname: string;
      pictureUrl: string;
    };
  };
  onDeleteComment: (comment: {id: string}) => Promise<void>;
}

export default class TranslationsCommentsListItem extends Component<Args> {
  @service('session')
  session: Session;

  @readOnly('session.credentials.user')
  currentUser: any;

  get isAuthor() {
    return this.currentUser.id === this.args.comment.user.id;
  }

  get text() {
    return htmlSafe(markdown.render(this.args.comment.text));
  }

  @dropTask
  *deleteComment() {
    yield this.args.onDeleteComment(this.args.comment);
  }
}
