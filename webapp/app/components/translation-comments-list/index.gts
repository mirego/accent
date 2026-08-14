import Component from '@glimmer/component';
import Item from 'accent-webapp/components/translation-comments-list/item/index';
import EmptyState from 'accent-webapp/components/empty-state/index';
import BubbleSvg from 'accent-webapp/svgs/assets/bubble.svg';
import t from 'ember-intl/helpers/t';

interface Args {
  comments: any;
  onDeleteComment: (comment: {id: string}) => Promise<void>;
  onUpdateComment: (comment: {id: string; text: string}) => Promise<void>;
}

export default class TranslationsCommentsList extends Component<Args> {
  <template>
    {{#if @comments}}
      <ul ...attributes class='translation-comments-list'>
        {{#each @comments key='id' as |comment|}}
          <li class='itemComment'>
            <Item
              @comment={{comment}}
              @onDeleteComment={{@onDeleteComment}}
              @onUpdateComment={{@onUpdateComment}}
            />
          </li>
        {{/each}}
      </ul>
    {{else}}
      <EmptyState
        @icon={{BubbleSvg}}
        @title={{t 'components.translation_comments_list.no_comments'}}
        @text={{t 'components.translation_comments_list.no_comments_text'}}
      />
    {{/if}}

    <style scoped>
      .translation-comments-list {
        position: relative;
        box-shadow:
          0 1px 4px var(--shadow-color),
          0 9px 19px var(--shadow-color);
        background: var(--background-light);
        border-radius: var(--border-radius);
      }

      .translation-comments-list.translationRemoved {
        opacity: 0.5;
      }
      .translation-comments-list.translationRemoved .itemComment {
        padding: 4px 8px 8px;
      }

      .translation-comments-list.at-translation {
        margin-top: 20px;
      }
      .translation-comments-list.at-translation:before,
      .translation-comments-list.at-translation:after {
        display: none;
      }

      .itemComment {
        padding: 8px 10px 10px;
        border-bottom: 1px solid var(--background-light-highlight);
      }
      .itemComment:focus,
      .itemComment:hover {
        background: var(--background-light);
      }
      .itemComment:last-of-type {
        border-bottom: 0;
      }

      @media (max-width: 1300px) {
        .translation-comments-list {
          border-color: transparent;
          box-shadow: none;
        }
      }
    </style>
  </template>
}
