import Component from '@glimmer/component';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import {Picker} from 'emoji-picker-element';
import type {EmojiClickEvent} from 'emoji-picker-element/shared';

interface Args {
  onPicked: (value: string) => void;
}

export default class EmojiPicker extends Component<Args> {
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
