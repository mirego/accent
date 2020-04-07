import Service, {inject as service} from '@ember/service';
import searchLanguagesQuery from 'accent-webapp/queries/languages-search';
import Apollo from 'accent-webapp/services/apollo';

const MINIMUM_TERM_LENGTH = 2;

export default class LanguageSearcher extends Service {
  @service('apollo')
  apollo: Apollo;

  async search({term}: {term: string}) {
    const searchQuery = {
      query: searchLanguagesQuery,
      variables: {query: term},
    };

    if (term.length < MINIMUM_TERM_LENGTH) return [];

    const {
      data: {
        languages: {entries},
      },
    } = await this.apollo.client.query(searchQuery);

    return entries;
  }
}

declare module '@ember/service' {
  interface Registry {
    'language-searcher': LanguageSearcher;
  }
}
