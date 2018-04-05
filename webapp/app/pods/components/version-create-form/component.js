import Component from '@ember/component';
import {scheduleOnce} from '@ember/runloop';

// Attributes:
// error: Boolean
// onCreate: Function
export default Component.extend({
  name: null,
  tag: null,
  isCreating: false,

  didInsertElement() {
    scheduleOnce('afterRender', this, function() {
      this.element.querySelector('.textInput').focus();
    });
  },

  actions: {
    submit() {
      this.set('isCreating', true);
      const tag = this.tag;
      const name = this.name;

      this.onCreate({tag, name}).then(() => {
        if (!this.isDestroyed) this.set('isCreating', false);
      });
    }
  }
});
