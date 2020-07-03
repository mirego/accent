import {helper} from '@ember/component/helper';

const DEFAULT_MAX_TEXT_LENGTH = 600;

const truncate = ([text, maxLength]: [string, number]) => {
  const maxTextLength = maxLength || DEFAULT_MAX_TEXT_LENGTH;
  if (text.length < maxTextLength) return text;

  return `${text.substring(0, maxTextLength - 1)}…`;
};

export default helper(truncate);
