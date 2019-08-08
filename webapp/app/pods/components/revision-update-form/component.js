import {computed} from '@ember/object';
import {reads} from '@ember/object/computed';
import {scheduleOnce} from '@ember/runloop';
import Component from '@ember/component';

// Attributes:
// revision: Object <revision>
// error: Boolean
// onUpdate: Function
export default Component.extend({
  name: reads('revision.name'),
  namePlaceholder: computed('revision.{name,language.name}', function() {
    return this.revision.name || this.revision.language.name;
  }),
  slug: reads('revision.slug'),
  slugPlaceholder: computed('revision.{slug,language.slug}', function() {
    return this.revision.slug || this.revision.language.slug;
  }),
  isUpdating: false,

  didInsertElement() {
    scheduleOnce('afterRender', this, function() {
      this.element.querySelector('.textInput').focus();
    });
  },

  actions: {
    submit() {
      this.set('isUpdating', true);
      const name = this.name;
      const slug = this.slug;

      this.onUpdate({name, slug}).then(() => {
        if (!this.isDestroyed) this.set('isUpdated', false);
      });
    }
  }
});
