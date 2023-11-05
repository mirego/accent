import {helper} from '@ember/component/helper';
import {htmlSafe} from '@ember/template';
import DiffMatchPatch from 'diff-match-patch';
const diffMatchPatch = new DiffMatchPatch();

const SIMILARITY_THRESHOLD = 0.4;

const createBigram = (word: string) => {
  const input = word.toLowerCase();
  const vector = [];
  for (let i = 0; i < input.length; ++i) {
    vector.push(input.slice(i, i + 2));
  }
  return vector;
};

const checkSimilarity = (a: string, b: string) => {
  if (a.length > 0 && b.length > 0) {
    const aBigram = createBigram(a);
    const bBigram = createBigram(b);
    let hits = 0;
    for (let x = 0; x < aBigram.length; ++x) {
      for (let y = 0; y < bBigram.length; ++y) {
        // eslint-disable-next-line max-depth
        if (aBigram[x] === bBigram[y]) hits += 1;
      }
    }
    if (hits > 0) {
      const union = aBigram.length + bBigram.length;
      return (2.0 * hits) / union;
    }
  }
  return 0;
};

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
const UNDIFFABLE_TAG_TEMPLATE = (value: string) =>
  `<span class="undiffable">${value}</span>`;

const stringDiff = ([text1, text2]: [string, string]) => {
  const similarity = checkSimilarity(text1, text2);
  if (similarity < SIMILARITY_THRESHOLD)
    return htmlSafe(UNDIFFABLE_TAG_TEMPLATE(text2));

  const diff = diffMatchPatch.diff_main(text2 || '', text1 || '');
  diffMatchPatch.diff_cleanupSemantic(diff);

  return htmlSafe(
    diff
      .map(([op, text]: [number, string]) => {
        const value = escapeExpression(text);
        if (op === -1) return REMOVED_TAG_TEMPLATE(value);
        if (op === 1) return ADDED_TAG_TEMPLATE(value);

        return value;
      })
      .join('')
  );
};

export default helper(stringDiff);
