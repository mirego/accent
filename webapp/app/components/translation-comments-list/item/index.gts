import {service} from '@ember/service';
import {action} from '@ember/object';
import Component from '@glimmer/component';
import MarkdownIt from 'markdown-it';
import {htmlSafe} from '@ember/template';
import Session from 'accent-webapp/services/session';
import {dropTask} from 'ember-concurrency';
import {tracked} from '@glimmer/tracking';
import AccAvatarImg from 'accent-webapp/components/acc-avatar-img/index';
import TimeAgoInWordsTag from 'accent-webapp/components/time-ago-in-words-tag/index';
import {on} from '@ember/modifier';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import TranslationCommentDelete from 'accent-webapp/components/translation-comment-delete/index';
import perform from 'ember-concurrency/helpers/perform';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import TranslationCommentForm from 'accent-webapp/components/translation-comment-form/index';

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
  <template>
    <div class='wrapper'>
      <div class='header'>
        <div class='meta'>
          <span class='user'>
            {{#if @comment.user.pictureUrl}}
              <AccAvatarImg
                src='{{@comment.user.pictureUrl}}'
                class='user-picture'
              />
            {{/if}}
            {{@comment.user.fullname}}
          </span>

          <span class='date'>
            <TimeAgoInWordsTag @date={{@comment.insertedAt}} />
          </span>
        </div>

        {{#if this.isAuthor}}
          <div>
            <button
              {{on 'click' this.toggleEditComment}}
              class='button button--small button--borderless button-edit'
            >
              {{#if this.editComment}}
                {{inlineSvg 'assets/x.svg' class='button-icon'}}
              {{else}}
                {{inlineSvg 'assets/pencil.svg' class='button-icon'}}
              {{/if}}
            </button>

            {{#unless this.editComment}}
              <TranslationCommentDelete
                class='button button--small button--red button--borderless button-delete'
                @onSubmit={{perform this.deleteComment}}
              >
                {{inlineSvg 'assets/x.svg' class='button-icon'}}
              </TranslationCommentDelete>
            {{/unless}}
          </div>
        {{/if}}
      </div>

      {{#if this.editComment}}
        <div class='comment-form' {{didInsert this.focusTextarea}}>
          <TranslationCommentForm
            @value={{@comment.text}}
            @onSubmit={{perform this.updateComment}}
          />
        </div>
      {{else}}
        <div class='content'>
          {{this.text}}
        </div>
      {{/if}}
    </div>
  </template>
  @service('session')
  declare session: Session;

  get currentUser() {
    return this.session.credentials.user;
  }

  @tracked
  editComment = false;

  get isAuthor() {
    return this.currentUser?.id === this.args.comment.user.id;
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
