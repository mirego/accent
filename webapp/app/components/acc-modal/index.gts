import Component from '@glimmer/component';
import onKey from 'ember-keyboard/modifiers/on-key';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';

interface Args {
  small: boolean;
  large: boolean;
  onClose: () => void;
}

export default class Modal extends Component<Args> {
  <template>
    {{#if this.destinationElement}}
      {{#in-element this.destinationElement}}
        <div class='wrapper' {{onKey 'Escape' @onClose}}>
          <div role='button' class='overlay' {{on 'click' (fn @onClose)}}></div>
          <div
            role='dialog'
            class='container
              {{if @small "container--small"}}
              {{if @large "container--large"}}'
          >
            {{yield}}
          </div>
        </div>
      {{/in-element}}
    {{/if}}
  </template>
  get destinationElement() {
    return document.getElementById('modals');
  }
}
