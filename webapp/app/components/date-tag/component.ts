import {inject as service} from '@ember/service';
import Component from '@glimmer/component';
import dateFormat from 'date-fns/format';
import IntlService from 'ember-intl/services/intl';

interface Args {
  date: string;
}

export default class DateTag extends Component<Args> {
  @service('intl')
  intl: IntlService;

  // The follow property returns a formatted date like this: 2016-02-03T11:02:34
  get formattedDatetime() {
    const format = this.intl
      .t('components.date_tag.formatted_date_time_format')
      .toString();

    return dateFormat(new Date(this.args.date), format);
  }

  // The follow property returns a formatted date like this: February 3rd 2016, 11:02:34
  get humanizedDate() {
    const format = this.intl
      .t('components.date_tag.humanized_date_title_format')
      .toString();

    return dateFormat(new Date(this.args.date), format);
  }
}
