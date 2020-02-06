import Ember from 'ember';
import {helper} from '@ember/component/helper';
import {htmlSafe} from '@ember/string';
import Diff from 'diff';

const {
  Handlebars: {
    Utils: {escapeExpression}
  }
} = Ember;

const REMOVED_TAG_TEMPLATE = (value: string) =>
  `<span class="removed">${value}</span>`;
const ADDED_TAG_TEMPLATE = (value: string) =>
  `<span class="added">${value}</span>`;

const stringDiff = ([text1, text2]: [string, string]) => {
  const diff = Diff.diffWords(text2 || '', text1 || '');

  return htmlSafe(
    diff
      .map((part: {value: string; removed: string; added: string}) => {
        const value = escapeExpression(part.value);
        if (part.removed) return REMOVED_TAG_TEMPLATE(value);
        if (part.added) return ADDED_TAG_TEMPLATE(value);

        return value;
      })
      .join('')
  );
};

export default helper(stringDiff);
