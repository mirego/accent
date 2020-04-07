import Component from '@glimmer/component';
import {action} from '@ember/object';
import EmojiButton from '@joeattardi/emoji-button';

interface Args {
  onPicked: () => string;
}

export default class EmojiPicker extends Component<Args> {
  picker: EmojiButton;
  element: HTMLDivElement;

  clickCallback = this.onClick.bind(this);

  @action
  initializePicker(element: HTMLDivElement) {
    this.element = element;

    this.picker = new EmojiButton({
      showPreview: false,
    });

    this.picker.on('emoji', this.args.onPicked);
  }

  @action
  destroyPicker() {
    this.picker.off('emoji', this.args.onPicked);
  }

  @action
  onClick() {
    this.picker.pickerVisible
      ? this.picker.hidePicker()
      : this.picker.showPicker(this.element);
  }
}
