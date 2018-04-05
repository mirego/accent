import {inject as service} from '@ember/service';
import {equal} from '@ember/object/computed';
import Controller from '@ember/controller';
import {computed} from '@ember/object';

const UNAUTHORIZED = 'unauthorized';
const INTERNAL_ERROR = 'internal_error';

const translationAttribute = attribute => {
  return computed('translationPrefix', function() {
    return this.i18n.t(`pods.error.${this.translationPrefix}.${attribute}`);
  });
};

export default Controller.extend({
  i18n: service('i18n'),
  session: service('session'),

  isUnauthorized: equal('firstError.status', '401'),

  title: translationAttribute('title'),
  status: translationAttribute('status'),
  text: translationAttribute('text'),

  firstError: computed('model.errors.[]', function() {
    return this.model.errors[0];
  }),

  translationPrefix: computed('isUnauthorized', function() {
    return this.isUnauthorized ? UNAUTHORIZED : INTERNAL_ERROR;
  }),

  actions: {
    logout() {
      this.session.logout();
      window.location = '/';
    }
  }
});
