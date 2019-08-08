import TextArea from '@ember/component/text-area';

const ENTER_KEY = 13;

export default TextArea.extend({
  focusIn() {
    if (this.onFocus) this.onFocus();
  },

  focusOut() {
    if (this.onBlur) this.onBlur();
  },

  keyUp(_event) {
    if (this.onKeyUp) this.onKeyUp();
  },

  keyDown(event) {
    if (event.which === ENTER_KEY && (event.metaKey || event.ctrlKey)) {
      if (this.onSubmit) this.onSubmit();
    }
  }
});
