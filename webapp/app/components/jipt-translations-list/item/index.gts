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
  </template>
  @equal('translation.valueType', 'EMPTY')
  isTextEmpty: boolean;
}
