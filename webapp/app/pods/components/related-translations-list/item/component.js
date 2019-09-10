import {computed} from '@ember/object';
import {reads, not} from '@ember/object/computed';
import Component from '@ember/component';

// Attributes:
// translation: Object <translation>
// onUpdateText: Fucntion
export default Component.extend({
  tagName: 'li',

  isSaving: false,
  showSaveButton: not('translation.isRemoved'),
  editText: reads('translation.correctedText'),

  revisionName: computed(
    'translation.revision.{name,language.name}',
    function() {
      return (
        this.translation.revision.name ||
        this.translation.revision.language.name
      );
    }
  ),

  actions: {
    save() {
      this.set('isSaving', true);

      this.onUpdateText(this.translation, this.editText).then(() => {
        this.set('isSaving', false);
      });
    }
  }
});
