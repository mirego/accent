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

    <style scoped>
      .wrapper {
        display: flex;
        align-items: flex-start;
        justify-content: center;
        position: fixed;
        z-index: 4000;
        height: 100vh;
        left: 0;
        right: 0;
        top: 0;
        overflow-y: scroll;
        padding: 100px 30px;
      }

      .overlay {
        position: fixed;
        top: 0;
        left: 0;
        bottom: 0;
        right: 0;
        min-height: calc(100vh - 130px);
        background-color: #000;
        opacity: 0.6;
        animation-name: animate-overlay;
        animation-timing-function: ease-out;
        animation-duration: 0.15s;
        animation-delay: 0;
        animation-fill-mode: forwards;
      }

      .container {
        display: block;
        position: relative;
        z-index: 3;
        border-radius: var(--border-radius);
        overflow: hidden;
        box-shadow: 0 2px 20px 0 var(--shadow-color);
        animation-name: animate-content;
        animation-timing-function: ease-in-out;
        animation-duration: 0.3s;
        animation-delay: 0;
        animation-fill-mode: forwards;
      }

      @media (max-width: 440px) {
        .wrapper {
          padding: 30px 10px;
        }
      }
      @keyframes animate-content {
        0% {
          opacity: 0;
          transform: translateY(10px);
        }
        100% {
          opacity: 1;
          transform: translateY(0);
        }
      }
      @keyframes animate-overlay {
        0% {
          opacity: 0;
        }
        100% {
          opacity: 0.6;
        }
      }
    </style>
  </template>
  @tracked
  picker?: Picker;

  get destinationElement() {
    return document.getElementById('emoji-picker');
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
