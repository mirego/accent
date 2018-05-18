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

  unusedInterpolations: computed('value', 'interpolations', function() {
    return this.interpolations.reduce((memo, interpolation) => {
      if (!this.value.includes(interpolation)) memo[interpolation] = true;
      return memo;
    }, {});
  })
});
