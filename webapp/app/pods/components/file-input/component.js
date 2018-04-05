import Component from '@ember/component';
import Evented from '@ember/object/evented';

const attributeBindings = ['name', 'disabled', 'form', 'type', 'accept', 'autofocus', 'required', 'multiple'];

// Attributes
// onChange: Function
export default Component.extend(Evented, {
  tagName: 'input',
  type: 'file',
  attributeBindings,

  change(event) {
    this.onChange(event.target.files);
  }
});
