import {computed} from '@ember/object';
import {empty, reads} from '@ember/object/computed';
import Component from '@ember/component';

import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';

// Attributes:
// project: Object <project>
// permissions: Ember Object containing <permission>
// conflict: Object <conflict>
// revision: Object <revision> (optional)
// onCorrect: Function
export default Component.extend({
  classNameBindings: ['active', 'resolved', 'error:errored', 'fullscreen'],

  emptyPreviousText: empty('conflict.conflictedText'),
  textInput: reads('conflict.correctedText'),
  samePreviousText: computed(
    'conflict.{conflictedText,correctedText}',
    function() {
      return this.conflict.conflictedText === this.conflict.correctedText;
    }
  ),

  loading: false,
  error: false,
  resolved: false,
  active: false,

  conflictKey: parsedKeyProperty('conflict.key'),

  actions: {
    correct() {
      this._onLoading();

      this.onCorrect(this.conflict, this.textInput)
        .then(this._onCorrectSuccess.bind(this))
        .catch(this._onError.bind(this));
    },

    inputBlur() {
      this.set('active', false);
    },

    inputFocus() {
      this.set('active', true);
    }
  },

  _onLoading() {
    this.setProperties({error: false, loading: true});
  },

  _onError() {
    this.setProperties({error: true, loading: false});
  },

  _onCorrectSuccess() {
    this.setProperties({resolved: true, loading: false});
  },

  _onUncorrectSuccess() {
    this.setProperties({resolved: false, loading: false});
  }
});
