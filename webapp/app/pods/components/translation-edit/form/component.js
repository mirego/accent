import {inject as service} from '@ember/service';
import {equal} from '@ember/object/computed';
import {debounce} from '@ember/runloop';
import {computed} from '@ember/object';
import Component from '@ember/component';

import translationLintQuery from 'accent-webapp/queries/lint-translation';

const DEBOUNCE_LINT_MESSAGES = 1000;
const SMALL_INPUT_ROWS = 1;
const MEDIUM_INPUT_ROWS = 3;
const LARGE_INPUT_ROWS = 7;
const SMALL_INPUT_VALUE = 70;
const LARGE_INPUT_VALUE = 100;

export default Component.extend({
  apollo: service('apollo'),

  lintMessages: () => [],

  rows: computed('value', function() {
    if (!this.value) return SMALL_INPUT_ROWS;
    if (this.value.length < SMALL_INPUT_VALUE) return SMALL_INPUT_ROWS;
    if (this.value.length < LARGE_INPUT_VALUE) return MEDIUM_INPUT_ROWS;

    return LARGE_INPUT_ROWS;
  }),
  showTypeHints: true,

  isStringType: equal('valueType', 'STRING'),
  isBooleanType: equal('valueType', 'BOOLEAN'),
  isIntegerType: equal('valueType', 'INTEGER'),
  isFloatType: equal('valueType', 'FLOAT'),
  isEmptyType: equal('valueType', 'EMPTY'),
  isNullType: equal('valueType', 'NULL'),

  unusedPlaceholders: computed('value', 'placeholders', function() {
    return this.placeholders.reduce((memo, placeholder) => {
      if (!this.value.includes(placeholder)) memo[placeholder] = true;
      return memo;
    }, {});
  }),

  didInsertElement() {
    this.send('changeText');
  },

  fetchLintMessages(event) {
    return () => {
      let text = this.value;
      if (event) text = event.target.value;

      this.apollo.client
        .query({
          query: translationLintQuery,
          variables: {
            text,
            projectId: this.projectId,
            translationId: this.translationId
          }
        })
        .then(({data}) => {
          if (this.isDestroyed) return;

          this.set(
            'lintMessages',
            data.viewer.project.translation.lintMessages
          );
        });
    };
  },

  actions: {
    changeText(event) {
      debounce(this, this.fetchLintMessages(event), DEBOUNCE_LINT_MESSAGES);

      if (this.onKeyUp) this.onKeyUp(event);
    },

    replaceText(context, replacement) {
      const wordToReplace = context.text.substring(
        context.offset,
        context.offset + context.length
      );
      const wordRegexp = new RegExp(wordToReplace, 'g');
      const newText = this.value.replace(wordRegexp, replacement.value);

      this.set('value', newText);
      this.send('changeText');
    }
  }
});
