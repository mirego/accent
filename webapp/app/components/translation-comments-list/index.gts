import Component from '@glimmer/component';
import Item from 'accent-webapp/components/translation-comments-list/item/index';
import EmptyContent from 'accent-webapp/components/empty-content/index';
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
      <EmptyContent
        @center={{true}}
        @iconPath='assets/bubble.svg'
        @text={{t 'components.translation_comments_list.no_comments'}}
      />
    {{/if}}
  </template>
}
