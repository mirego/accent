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
  </template>
}
