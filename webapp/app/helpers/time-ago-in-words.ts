import {isBlank} from '@ember/utils';
import {helper} from '@ember/component/helper';
import formatDistanceToNow from 'date-fns/formatDistanceToNow';

const OPTIONS = {
  addSuffix: true,
  includeSeconds: false,
};

const timeAgoInWords = ([date]: [string]) => {
  if (isBlank(date)) return '';

  return formatDistanceToNow(new Date(date), OPTIONS);
};

export default helper(timeAgoInWords);
