import Component from '@glimmer/component';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import {Picker} from 'emoji-picker-element';
import type {EmojiClickEvent} from 'emoji-picker-element/shared';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import onKey from 'ember-keyboard/modifiers/on-key';

interface Args {
  onPicked: (value: string) => void;
}

export default class EmojiPicker extends Component<Args> {
  <template>
    <button {{on 'click' (fn this.togglePicker)}} ...attributes>
      <div>
        {{yield}}
      </div>
    </button>

    {{#if this.destinationElement}}
      {{#if this.picker}}
        {{#in-element this.destinationElement}}
          <div class='wrapper' {{onKey 'Escape' this.togglePicker}}>
            <div
              role='button'
              class='overlay'
              {{on 'click' (fn this.togglePicker)}}
            ></div>
            <div role='dialog' class='container'>
              {{this.picker}}
            </div>
          </div>
        {{/in-element}}
      {{/if}}
    {{/if}}
  </template>
  @tracked
  picker?: Picker;

  get destinationElement() {
    return document.getElementById('modals');
  }

  @action
  togglePicker() {
    if (this.picker) {
      this.picker = undefined;
    } else {
      this.picker = new Picker({locale: 'fr'});
      this._bindClick(this.picker);
    }
  }

  _bindClick(picker: Picker) {
    picker.addEventListener('emoji-click', (event: EmojiClickEvent) => {
      if (!event.detail.unicode) return;

      this.args.onPicked(event.detail.unicode);
      this.togglePicker();
    });
  }
}
