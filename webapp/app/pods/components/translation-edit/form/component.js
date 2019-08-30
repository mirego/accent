import {equal} from '@ember/object/computed';
import {computed} from '@ember/object';
import Component from '@ember/component';

const SMALL_INPUT_ROWS = 1;
const MEDIUM_INPUT_ROWS = 3;
const LARGE_INPUT_ROWS = 7;
const SMALL_INPUT_VALUE = 70;
const LARGE_INPUT_VALUE = 100;

export default Component.extend({
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
  })
});
