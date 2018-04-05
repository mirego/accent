import {computed} from '@ember/object';
import Component from '@ember/component';
import {htmlSafe} from '@ember/string';

// Attributes:
// correctedKeysPercentage: Number
export default Component.extend({
  progressStyles: computed('correctedKeysPercentage', function() {
    let percentage = this.correctedKeysPercentage;
    if (percentage < 1 && percentage !== 0) percentage = 1;

    return htmlSafe(`width: ${percentage}%`);
  })
});
