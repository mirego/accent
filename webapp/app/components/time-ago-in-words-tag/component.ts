import {inject as service} from '@ember/service';
import Component from '@glimmer/component';
import dateFormat from 'date-fns/format';
import IntlService from 'ember-intl/services/intl';

interface Args {
  date: string;
}

export default class TimeAgoInWordsTag extends Component<Args> {
  @service('intl')
  intl: IntlService;

  // The follow property returns a formatted date like this: 2016-02-03T11:02:34
  get formattedDatetime() {
    if (!this.args.date) return null;

    const format = this.intl
      .t('components.time_ago_in_words_tag.formatted_date_time_format')
      .toString();

    return dateFormat(new Date(this.args.date), format);
  }

  // The follow property returns a formatted date like this: Wednesday, February 2 2016, 11:02 am
  get humanizedDate() {
    if (!this.args.date) return null;

    const format = this.intl
      .t('components.time_ago_in_words_tag.humanized_date_title_format')
      .toString();

    return dateFormat(new Date(this.args.date), format);
  }
}
