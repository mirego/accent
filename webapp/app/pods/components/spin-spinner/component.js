import {on} from '@ember/object/evented';
import Component from '@ember/component';

const defaultConfig = {
  color: '#333',
  corners: 1,
  direction: 1,
  fps: 20,
  length: 7,
  lines: 12,
  opacity: 0.25,
  radius: 10,
  rotate: 0,
  scale: 1.0,
  shadow: false,
  speed: 1,
  top: '0',
  left: '0',
  trail: 100,
  width: 5,
  zIndex: 2000,
  spinner: null,
  hwaccel: true
};

export default Component.extend({
  ...defaultConfig,
  lookupUpConfig: on('willInsertElement', function() {
    this.spinnerArgs = this.getProperties(Object.keys(defaultConfig));
  }),

  didInsertElement() {
    this.spinner = new Spinner(this.spinnerArgs).spin(this.element);
  },

  willRemoveElement() {
    this.spinner.stop();
  }
});
