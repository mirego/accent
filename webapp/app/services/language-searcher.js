import Service, {inject as service} from '@ember/service';
import RSVP from 'rsvp';

import searchLanguagesQuery from 'accent-webapp/queries/languages-search';

const MINIMUM_TERM_LENGTH = 2;

export default Service.extend({
  apollo: service('apollo'),

  search({term}) {
    const searchQuery = {
      query: searchLanguagesQuery,
      variables: {query: term}
    };

    return new RSVP.Promise(resolve => {
      if (term.length < MINIMUM_TERM_LENGTH) return resolve([]);

      return this.apollo.client
        .query(searchQuery)
        .then(({data: {languages: {entries}}}) => {
          return resolve(entries);
        });
    });
  }
});
