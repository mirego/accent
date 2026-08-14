import {equal} from '@ember/object/computed';
import Component from '@glimmer/component';
import t from 'ember-intl/helpers/t';

interface Args {
  translation: any;
}

export default class JIPTTranslationsListItem extends Component<Args> {
  <template>
    {{#if this.isTextEmpty}}
      <span class='item-text item-text--empty'>{{t
          'components.translations_list.empty_text'
        }}</span>
    {{else}}
      <span class='item-text'>
        {{@translation.correctedText}}
        <span class='item-key'>{{@translation.key}}</span>
      </span>
    {{/if}}

    <style scoped>
      .item-text {
        display: flex;
        flex-direction: column;
        text-overflow: ellipsis;
        overflow-x: hidden;
        color: var(--text-color-normal);
        font-size: 16px;
      }
      .item-text.item-text--empty {
        color: var(--color-grey);
        font-style: italic;
      }
      .item-text .item-key {
        opacity: 0.5;
        font-size: 11px;
        font-family: var(--font-monospace);
      }
    </style>
  </template>
  @equal('translation.valueType', 'EMPTY')
  isTextEmpty: boolean;
}
