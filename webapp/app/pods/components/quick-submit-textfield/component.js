import TextField from '@ember/component/text-field';

const ENTER_KEY = 13;

export default TextField.extend({
  focusIn() {
    if (this.onFocus) this.onFocus();
  },

  focusOut() {
    if (this.onBlur) this.onBlur();
  },

  keyUp() {
    if (this.onKeyUp) this.onKeyUp();
  },

  keyDown(event) {
    if (event.which === ENTER_KEY && (event.metaKey || event.ctrlKey)) {
      if (this.onSubmit) this.onSubmit();
    }
  },
});
