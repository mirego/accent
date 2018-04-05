import {equal} from '@ember/object/computed';
import Component from '@ember/component';

export default Component.extend({
  rows: 10,
  showTypeHints: true,

  isStringType: equal('valueType', 'STRING'),
  isBooleanType: equal('valueType', 'BOOLEAN'),
  isIntegerType: equal('valueType', 'INTEGER'),
  isEmptyType: equal('valueType', 'EMPTY'),
  isNullType: equal('valueType', 'NULL')
});
