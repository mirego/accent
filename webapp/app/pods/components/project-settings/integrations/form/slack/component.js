import Component from '@ember/component';
import fieldError from 'accent-webapp/computed-macros/field-error';

export default Component.extend({
  urlError: fieldError('errors', 'data.url')
});
