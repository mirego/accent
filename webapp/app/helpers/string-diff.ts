import {helper} from '@ember/component/helper';
import {htmlSafe} from '@ember/string';
import Diff from 'diff';

const badChars = /[&<>"'`=]/g;
const possible = /[&<>"'`=]/;
const escape = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#x27;',
  '`': '&#x60;',
  '=': '&#x3D;',
};

const escapeChar = (chr: keyof typeof escape) => {
  return escape[chr];
};

const escapeExpression = (string: any): string => {
  if (typeof string !== 'string') {
    // don't escape SafeStrings, since they're already safe
    if (string && string.toHTML) {
      return string.toHTML();
    } else if (string === null || string === undefined) {
      return '';
    } else if (!string) {
      return String(string);
    }

    // Force a string conversion as this will be done by the append regardless and
    // the regex test will do this transparently behind the scenes, causing issues if
    // an object's to string has escaped characters in it.
    string = String(string);
  }

  if (!possible.test(string)) return string;

  return string.replace(badChars, escapeChar);
};

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
