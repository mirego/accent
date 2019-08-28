import {equal} from '@ember/object/computed';
import {computed} from '@ember/object';
import Component from '@ember/component';

export default Component.extend({
  rows: computed('value', function() {
    if (!this.value) return 1;
    if (this.value.length < 70) return 1;
    if (this.value.length < 300) return 3;

    return 7;
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
