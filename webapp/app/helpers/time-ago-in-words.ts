import {isBlank} from '@ember/utils';
import {helper} from '@ember/component/helper';
import {formatDistanceToNow} from 'date-fns';
import {frCA, enUS} from 'date-fns/locale';

const LOCALES = {
  'fr-ca': frCA,
  'en-us': enUS,
  'zh-cn': zhCN
} as any;

const OPTIONS = {
  addSuffix: true,
  includeSeconds: false
};

const timeAgoInWords = ([date]: [string]) => {
  if (isBlank(date)) return '';
  const locale = LOCALES[localStorage.getItem('locale') || 'en-us'] || enUS;

  const options = {
    locale,
    ...OPTIONS
  };

  return formatDistanceToNow(new Date(date), options);
};

export default helper(timeAgoInWords);
