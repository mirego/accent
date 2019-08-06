import {computed} from '@ember/object';
import {inject as service} from '@ember/service';
import Component from '@ember/component';
import dateFormat from 'date-fns/format';

// Attributes:
// date: String <translation>
export default Component.extend({
  intl: service('intl'),

  tagName: 'span',

  // The follow property returns a formatted date like this: 2016-02-03T11:02:34
  formattedDatetime: computed('date', function() {
    const format = this.intl
      .t('components.date_tag.formatted_date_time_format')
      .toString();
    return dateFormat(new Date(this.date), format);
  }),

  // The follow property returns a formatted date like this: February 3rd 2016, 11:02:34
  humanizedDate: computed('date', function() {
    const format = this.intl
      .t('components.date_tag.humanized_date_title_format')
      .toString();
    return dateFormat(new Date(this.date), format);
  })
});
