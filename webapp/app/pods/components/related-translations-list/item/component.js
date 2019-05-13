import {computed} from '@ember/object';
import {reads, not} from '@ember/object/computed';
import Component from '@ember/component';
import {run} from '@ember/runloop';

// Attributes:
// translation: Object <translation>
// onUpdateText: Fucntion
export default Component.extend({
  tagName: 'li',

  classNameBindings: ['isInEditMode:item--editMode'],

  isSaving: false,
  isInEditMode: false,
  showEditButton: not('translation.isRemoved'),
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

        if (this.showEditButton) {
          this.toggleProperty('isInEditMode');
        }
      });
    },

    toggleEdit() {
      this.set('editText', this.translation.correctedText);
      this.toggleProperty('isInEditMode');

      if (this.isInEditMode) {
        run.next(this, function() {
          this.element.querySelector('.textEdit-input').focus();
        });
      }
    }
  }
});
