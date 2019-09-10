import Component from '@ember/component';
import {computed} from '@ember/object';
import {gt} from '@ember/object/computed';

export default Component.extend({
  multipleReplacements: gt('mappedReplacements', 1),

  selectedReplacement: computed('attrs.message.replacements', function() {
    const replacement = this.attrs.message.replacements[0];

    return {
      label: replacement.value,
      value: replacement.value
    };
  }),

  mappedReplacements: computed('attrs.message.replacements', function() {
    return this.attrs.message.replacements.slice(0, 10).map(replacement => {
      return {
        label: replacement.value,
        value: replacement.value
      };
    });
  }),

  actions: {
    replaceTextSelected() {
      const replacement = this.selectedReplacement;
      this.onReplaceText(this.attrs.message.context, replacement);
    },

    replaceText(value) {
      const replacement = this.attrs.message.replacements.find(
        replacement => replacement.value === value
      );
      this.onReplaceText(this.attrs.message.context, replacement);
    }
  }
});
