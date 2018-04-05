import Component from '@ember/component';

import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';

// Attributes:
// groupedComment: Object
export default Component.extend({
  tagName: 'li',

  translationKey: parsedKeyProperty('groupedComment.value.key')
});
