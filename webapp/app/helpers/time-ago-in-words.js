import {isBlank} from '@ember/utils';
import {helper} from '@ember/component/helper';
import distanceInWordsToNow from 'npm:date-fns/distance_in_words_to_now';

const OPTIONS = {
  addSuffix: true,
  includeSeconds: false
};

const timeAgoInWords = ([date]) => {
  if (isBlank(date)) return '';

  return distanceInWordsToNow(new Date(date), OPTIONS);
};

export default helper(timeAgoInWords);
