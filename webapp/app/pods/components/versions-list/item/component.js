import Component from '@ember/component';

// Attributes:
// project: Object <project>
// permissions: Ember Object containing <permission>
// document: Object <revision>
// onDelete: Function
export default Component.extend({
  tagName: 'li',

  classNames: ['item']
});
