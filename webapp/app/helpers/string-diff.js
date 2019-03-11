import Ember from 'ember';
const {
  Handlebars: {
    Utils: {escapeExpression}
  }
} = Ember;

import {helper} from '@ember/component/helper';
import {htmlSafe} from '@ember/string';

const REMOVED_TAG_TEMPLATE = value => `<span class="removed">${value}</span>`;
const ADDED_TAG_TEMPLATE = value => `<span class="added">${value}</span>`;

const stringDiff = ([text1, text2]) => {
  const diff = JsDiff.diffWords(text2 || '', text1 || '');

  return htmlSafe(
    diff
      .map(part => {
        const value = escapeExpression(part.value);
        if (part.removed) return REMOVED_TAG_TEMPLATE(value);
        if (part.added) return ADDED_TAG_TEMPLATE(value);

        return value;
      })
      .join('')
  );
};

export default helper(stringDiff);
