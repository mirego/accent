import {reads} from '@ember/object/computed';
import Component from '@ember/component';

export default Component.extend({
  classNameBindings: [':button', 'loading:button--loading'],
  tagName: 'button',
  attributeBindings: ['disabled', 'type'],

  disabled: reads('loading'),
  loading: false,

  click() {
    if (this.disabled) return;
    const click = this.onClick;

    if (typeof click === 'function') click();
  }
});
