import {equal} from '@ember/object/computed';
import {computed} from '@ember/object';
import Component from '@ember/component';

export default Component.extend({
  rows: 10,
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
