import Component from '@ember/component';
import fieldError from 'accent-webapp/computed-macros/field-error';

export default Component.extend({
  tokenError: fieldError('errors', 'data.token'),
  repositoryError: fieldError('errors', 'data.repository'),
  defaultRefError: fieldError('errors', 'data.defaultRef')
});
