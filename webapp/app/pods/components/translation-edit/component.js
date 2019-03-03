import {computed} from '@ember/object';
import {reads} from '@ember/object/computed';
import Component from '@ember/component';

// Attributes:
// translation: Object <translation>
// permissions: Ember Object containing <permission>
// onUpdateText: Function
// onCorrectConflict: Function
// onUncorrectConflict: Function
export default Component.extend({
  isCorrectingConflict: false,
  isUncorrectingConflict: false,
  isUpdatingText: false,

  text: reads('translation.correctedText'),
  samePreviousText: computed('translation.{conflictedText,correctedText}', function() {
    return this.translation.conflictedText === this.translation.correctedText;
  }),

  hasTextNotChanged: computed('text', 'translation.correctedText', function() {
    if (!this.translation) return false;

    return this.text === this.translation.correctedText;
  }),

  didUpdateAttrs() {
    this._super(...arguments);

    if (this.translation) {
      this.set('text', this.translation.correctedText);
    }
  },

  actions: {
    correctConflict() {
      this.set('isCorrectingConflict', true);

      this.onCorrectConflict(this.text).then(() => this.set('isCorrectingConflict', false));
    },

    uncorrectConflict() {
      this.set('isUncorrectingConflict', true);

      this.onUncorrectConflict().then(() => this.set('isUncorrectingConflict', false));
    },

    updateText() {
      this.set('isUpdatingText', true);

      this.onUpdateText(this.text).then(() => this.set('isUpdatingText', false));
    },

    changeText() {
      if (!this.onChangeText) return;

      this.onChangeText(this.text);
    }
  }
});
