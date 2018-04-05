import {computed} from '@ember/object';
import {inject as service} from '@ember/service';
import {htmlSafe} from '@ember/string';
import {not, reads} from '@ember/object/computed';
import Component from '@ember/component';

// Attributes:
// languages: Array of <language>
// onCreate: Function
export default Component.extend({
  languageSearcher: service('language-searcher'),

  languagesCopy: reads('languages'),
  isLoading: false,

  emptyLanguage: not('language'),

  language: computed('mappedLanguages.[]', function() {
    const first = this.mappedLanguages[0];

    return first ? first.value : null;
  }),

  languageValue: computed('language', 'mappedLanguages.[]', function() {
    return this.mappedLanguages.find(({value}) => value === this.language);
  }),

  mappedLanguages: computed('languagesCopy.[]', function() {
    if (!this.languagesCopy) return [];

    return this._mapLanguages(this.languagesCopy);
  }),

  actions: {
    submit() {
      this.set('isLoading', true);

      this.onCreate(this.language).then(() => this.set('isLoading', false));
    },

    searchLanguages(term) {
      return this.languageSearcher.search({term}).then(languages => {
        this.set('languagesCopy', languages);

        return this._mapLanguages(languages);
      });
    }
  },

  _mapLanguages(languages) {
    return languages.map(({id, name, slug}) => {
      const label = htmlSafe(`${name} <em>${slug}</em>`);

      return {label, value: id};
    });
  }
});
