import Component from '@glimmer/component';
import Item from 'accent-webapp/components/related-translations-list/item/index';

interface Args {
  project: any;
  permissions: any;
  prompts: any[];
  translations: any;
  onUpdateText: (translation: any, text: string) => Promise<void>;
}
export default class RelatedTranslationsList extends Component<Args> {
  <template>
    {{#if @translations}}
      <div class='list'>
        <ul>
          {{#each @translations key='id' as |translation|}}
            <Item
              @permissions={{@permissions}}
              @prompts={{@prompts}}
              @onUpdateText={{@onUpdateText}}
              @isInEditMode={{true}}
              @showEditButton={{false}}
              @translation={{translation}}
              @project={{@project}}
            />
          {{/each}}
        </ul>
      </div>
    {{/if}}

    <style scoped>
      .list {
        width: 100%;
      }
    </style>
  </template>
}
