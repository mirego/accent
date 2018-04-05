import {computed} from '@ember/object';
import {readOnly} from '@ember/object/computed';
import Component from '@ember/component';

export default Component.extend({
  classNameBindings: ['isExiting', 'type'],

  isExiting: readOnly('flash.exiting'),
  type: readOnly('flash.type'),

  iconPath: computed('type', function() {
    switch (this.type) {
      case 'success':
        return 'assets/check.svg';
      case 'error':
        return 'assets/x.svg';
      case 'socket':
        return 'assets/activity.svg';
      default:
        null;
    }
  }),

  actions: {
    close() {
      const flash = this.flash;

      if (flash) flash.destroyMessage();
    }
  }
});
