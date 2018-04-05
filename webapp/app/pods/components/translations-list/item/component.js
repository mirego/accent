import {reads, equal} from '@ember/object/computed';
import Component from '@ember/component';
import {run} from '@ember/runloop';

import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';

// Attributes:
// project: Object <project>
// revisionId: ID
// translation: Object <translation>
// onUpdateText: Function
export default Component.extend({
  classNameBindings: ['isInEditMode:item--editMode'],
  tag: 'li',

  isSaving: false,
  isInEditMode: false,
  editText: reads('translation.correctedText'),
  isTextEmpty: equal('translation.valueType', 'EMPTY'),

  translationKey: parsedKeyProperty('translation.key'),

  actions: {
    save() {
      this.set('isSaving', true);

      this.onUpdateText(this.translation, this.editText).then(() => {
        this.set('isSaving', false);
        this.toggleProperty('isInEditMode');
      });
    },

    toggleEdit() {
      this.set('editText', this.translation.correctedText);
      this.toggleProperty('isInEditMode');

      if (this.isInEditMode) {
        run.next(this, function() {
          const input = this.element.querySelector('textarea');
          if (input) input.focus();
        });
      }
    }
  }
});
