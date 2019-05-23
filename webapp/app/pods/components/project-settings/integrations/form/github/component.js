import fmt from 'npm:simple-fmt';
import Component from '@ember/component';
import {computed} from '@ember/object';
import fieldError from 'accent-webapp/computed-macros/field-error';
import config from 'accent-webapp/config/environment';

export default Component.extend({
  tokenError: fieldError('errors', 'data.token'),
  repositoryError: fieldError('errors', 'data.repository'),
  defaultRefError: fieldError('errors', 'data.defaultRef'),

  webhookUrl: computed('project.id', function() {
    if (!this.project.accessToken) return;

    return fmt(
      config.API.HOOKS_PATH,
      'github',
      this.project.id,
      this.project.accessToken
    );
  })
});
