import {equal} from '@ember/object/computed';
import Component from '@ember/component';

// Attributes:
// translation: Object <translation>
export default Component.extend({
  isTextEmpty: equal('translation.valueType', 'EMPTY')
});
