import Component from '@ember/component';
import EmojiButton from '@joeattardi/emoji-button';

export default Component.extend({
  didInsertElement() {
    const button = this.element;
    const picker = new EmojiButton({
      showPreview: false
    });

    picker.on('emoji', this.onPicked);

    button.addEventListener('click', () => {
      picker.pickerVisible ? picker.hidePicker() : picker.showPicker(button);
    });
  }
});
