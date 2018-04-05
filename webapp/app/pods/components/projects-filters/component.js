import {observer} from '@ember/object';
import {inject as service} from '@ember/service';
import {reads} from '@ember/object/computed';
import Component from '@ember/component';
import {run} from '@ember/runloop';

const DEBOUNCE_OFFSET = 500; // ms

// Attributes:
// query: String
// onChangeQuery: Function
export default Component.extend({
  session: service(),

  debouncedQuery: reads('query'),

  queryDidChanges: observer('debouncedQuery', function() {
    run.debounce(this, this._debounceQuery, DEBOUNCE_OFFSET);
  }),

  _debounceQuery() {
    this.onChangeQuery(this.debouncedQuery);
  },

  actions: {
    submitForm() {
      this._debounceQuery();
    }
  }
});
