import {computed} from '@ember/object';
import {inject as service} from '@ember/service';
import Component from '@ember/component';
import dateFormat from 'npm:date-fns/format';

// Attributes:
// date: String <translation>
export default Component.extend({
  i18n: service(),

  attributeBindings: ['formattedDatetime:datetime', 'humanizedDate:title'],

  tagName: 'time',

  // The follow property returns a formatted date like this: 2016-02-03T11:02:34
  formattedDatetime: computed('date', function() {
    const format = this.i18n.t('components.time_ago_in_words_tag.formatted_date_time_format').toString();
    return dateFormat(new Date(this.date), format); // Ex.: 2016-02-03T11:02:34
  }),

  // The follow property returns a formatted date like this: Wednesday, February 2 2016, 11:02 am
  humanizedDate: computed('date', function() {
    const format = this.i18n.t('components.time_ago_in_words_tag.humanized_date_title_format').toString();
    return dateFormat(new Date(this.date), format); // Ex.: 2016-02-03T11:02:34
  })
});
