import Component from '@glimmer/component';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';
import {LinkTo} from '@ember/routing';
import {array} from '@ember/helper';
import t from 'ember-intl/helpers/t';
import timeAgoInWords from 'accent-webapp/helpers/time-ago-in-words';
import TranslationCommentsList from 'accent-webapp/components/translation-comments-list/index';

interface Args {
  groupedComment: any;
  project: any;
  onUpdateComment: (comment: {id: string; text: string}) => Promise<void>;
  onDeleteComment: (comment: {id: string}) => Promise<void>;
}

export default class ProjectCommentsListItem extends Component<Args> {
  <template>
    <li class='project-comments-list-item'>
      <div class='item-header'>
        <LinkTo
          @route='logged-in.project.revision.translations'
          @models={{array @project.id @groupedComment.value.revision.id}}
          class='item-language'
        >
          {{@groupedComment.value.revision.language.name}}
        </LinkTo>
        <LinkTo
          @route='logged-in.project.translation.comments'
          @models={{array @project.id @groupedComment.value.id}}
          class='item-link'
        >
          <small class='item-key-prefix'>
            {{#if this.translationKey.prefix}}
              {{this.translationKey.prefix}}
            {{else}}
              {{@groupedComment.value.document.path}}
            {{/if}}
          </small>
          {{this.translationKey.value}}
        </LinkTo>
        {{#if @groupedComment.value.removed}}
          <div class='removedBadge'>
            {{t
              'components.translation_splash_title.removed_label'
              removedAt=(timeAgoInWords @groupedComment.value.updatedAt)
            }}
          </div>
        {{/if}}
      </div>

      <TranslationCommentsList
        @comments={{@groupedComment.items}}
        @onDeleteComment={{@onDeleteComment}}
        @onUpdateComment={{@onUpdateComment}}
        class={{if
          @groupedComment.value.removed
          'translationCommentsList translationRemoved'
          'translationCommentsList'
        }}
      />
    </li>

    <style scoped>
      .project-comments-list-item {
        margin-bottom: 45px;
      }

      .translationCommentsList {
        border-radius: var(--border-radius);
      }

      .item-link {
        transition: 0.2s ease-in-out;
        transition-property: color;
        display: inline-block;
        color: var(--color-primary);
        word-break: break-all;
        font-family: var(--font-monospace);
        font-size: 12px;
        font-weight: bold;
        text-decoration: none;
      }
      .item-link:focus,
      .item-link:hover {
        color: color-mix(in srgb, var(--color-primary) 90%, black);
      }

      .item-header {
        margin-bottom: 10px;
      }

      .item-key-prefix {
        display: block;
        margin: 6px 0 0;
        font-size: 11px;
        color: #959595;
        font-weight: 300;
      }

      .item-language {
        transition: 0.2s ease-in-out;
        transition-property: color;
        display: block;
        font-size: 12px;
        text-decoration: none;
        color: var(--color-black);
      }

      .item-badge {
        font-size: 12px;
        color: var(--color-primary);
        text-decoration: none;
      }

      .removedBadge {
        display: block;
        margin-top: 5px;
        font-size: 12px;
        color: var(--color-error);
      }
    </style>
  </template>
  translationKey = parsedKeyProperty(this.args.groupedComment.value.key);
}
