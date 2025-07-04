import {service} from '@ember/service';
import {readOnly} from '@ember/object/computed';
import {action} from '@ember/object';
import Component from '@glimmer/component';
import MarkdownIt from 'markdown-it';
import {htmlSafe} from '@ember/template';
import Session from 'accent-webapp/services/session';
import {dropTask} from 'ember-concurrency';
import {tracked} from '@glimmer/tracking';

const markdown = MarkdownIt({
  html: false,
  linkify: true,
  typographer: true
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
  onUpdateComment: (comment: {id: string; text: string}) => Promise<void>;
  onDeleteComment: (comment: {id: string}) => Promise<void>;
}

export default class TranslationsCommentsListItem extends Component<Args> {
  @service('session')
  declare session: Session;

  @readOnly('session.credentials.user')
  currentUser: any;

  @tracked
  editComment = false;

  get isAuthor() {
    return this.currentUser.id === this.args.comment.user.id;
  }

  get text() {
    return htmlSafe(markdown.render(this.args.comment.text));
  }

  @action
  toggleEditComment() {
    this.editComment = !this.editComment;
  }

  @action
  focusTextarea(element: HTMLElement) {
    element.querySelector('textarea')?.focus();
  }

  deleteComment = dropTask(async () => {
    await this.args.onDeleteComment(this.args.comment);
  });

  updateComment = dropTask(async (text: string) => {
    await this.args.onUpdateComment({...this.args.comment, text});

    this.editComment = false;
  });
}
