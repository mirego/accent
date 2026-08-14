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
import PencilSvg from 'accent-webapp/svgs/assets/pencil.svg';
import XSvg from 'accent-webapp/svgs/assets/x.svg';
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
                <XSvg class='button-icon' />
              {{else}}
                <PencilSvg class='button-icon' />
              {{/if}}
            </button>

            {{#unless this.editComment}}
              <TranslationCommentDelete
                class='button button--small button--red button--borderless button-delete'
                @onSubmit={{perform this.deleteComment}}
              >
                <XSvg class='button-icon' />
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

    <style scoped>
      .header {
        display: flex;
        align-items: center;
        justify-content: space-between;
      }

      .wrapper:focus .button-edit,
      .wrapper:focus .button-delete,
      .wrapper:hover .button-edit,
      .wrapper:hover .button-delete {
        opacity: 1;
        transform: translate3d(0, 0, 0);
      }

      :global(.button.button--small).button-edit {
        padding: 0;
        color: var(--color-grey);
      }

      :global(.button).button-edit,
      :global(.button).button-delete {
        opacity: 0;
        transform: translate3d(10px, 0, 0);
      }
      :global(.button).button-edit:hover,
      :global(.button).button-delete:hover {
        background: transparent;
      }

      .comment-form {
        margin-top: 10px;
      }

      .user {
        display: inline-flex;
        align-items: center;
        margin-right: 6px;
        font-size: 12px;
        font-weight: bold;
      }

      .user-picture {
        width: 16px;
        height: 16px;
        margin-right: 6px;
        border-radius: var(--border-radius);
      }

      .date {
        color: var(--color-grey);
        font-size: 11px;
        margin-right: 6px;
      }

      .content {
        font-size: 13px;
      }
      .content h1,
      .content h2,
      .content h3,
      .content h4,
      .content h5,
      .content p {
        margin-top: 5px;
      }
    </style>
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
