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
  </template>
  translationKey = parsedKeyProperty(this.args.groupedComment.value.key);
}
