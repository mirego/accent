import Component from '@glimmer/component';
import AccFlashMessage from 'accent-webapp/components/acc-flash-message/index';

interface Args {
  flashMessages: any;
}

export default class FlashMessagesList extends Component<Args> {
  <template>
    <div class='flash-messages-list'>
      {{#each @flashMessages.queue as |flash|}}
        <AccFlashMessage @flash={{flash}} />
      {{/each}}
    </div>
  </template>
}
