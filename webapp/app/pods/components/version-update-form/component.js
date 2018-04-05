import {reads} from '@ember/object/computed';
import {scheduleOnce} from '@ember/runloop';
import Component from '@ember/component';

// Attributes:
// version: Object <version>
// error: Boolean
// onCreate: Function
export default Component.extend({
  name: reads('version.name'),
  tag: reads('version.tag'),
  isSubmitting: false,

  didInsertElement() {
    scheduleOnce('afterRender', this, function() {
      this.element.querySelector('.textInput').focus();
    });
  },

  actions: {
    submit() {
      this.set('isSubmitting', true);
      const tag = this.tag;
      const name = this.name;

      this.onUpdate({tag, name}).then(() => {
        if (!this.isDestroyed) this.set('isSubmitting', false);
      });
    }
  }
});
