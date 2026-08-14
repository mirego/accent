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

    <style scoped>
      .flash-messages-list {
        position: fixed;
        bottom: 20px;
        right: 20px;
        width: 100%;
        display: flex;
        align-items: flex-end;
        justify-content: center;
        flex-direction: column;
        z-index: 5001;
        pointer-events: none;
      }
    </style>
  </template>
}
