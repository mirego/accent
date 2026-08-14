import Component from '@glimmer/component';
import {LinkTo} from '@ember/routing';
import Item from 'accent-webapp/components/jipt-translations-list/item/index';

interface Args {
  translations: any;
}

export default class JIPTTranslationsList extends Component<Args> {
  <template>
    <div class='jipt-translations-list'>
      {{#each @translations key='id' as |translation|}}
        <LinkTo
          @route='logged-in.jipt.translation'
          @model={{translation.id}}
          class='item'
        >
          <Item @translation={{translation}} />
        </LinkTo>
      {{/each}}
    </div>

    <style scoped>
      .item {
        display: block;
        border-bottom: 1px solid #eee;
        padding: 7px 15px;
        text-decoration: none;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        transition: 0.2s ease-in-out;
        transition-property: padding, background;
      }
      .item:focus,
      .item:hover {
        background: var(--background-light);
        color: var(--color-black);
      }
    </style>
  </template>
}
