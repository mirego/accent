import {computed} from '@ember/object';
import {scheduleOnce} from '@ember/runloop';
import {inject as service} from '@ember/service';
import {reads, not} from '@ember/object/computed';
import {htmlSafe} from '@ember/string';
import Component from '@ember/component';

// Attributes:
// languages: Array of <language>
// error: Boolean
// onCreate: Function
export default Component.extend({
  languageSearcher: service('language-searcher'),

  name: null,
  mainColor: '#28cb87',
  languagesCopy: reads('languages'),
  emptyLanguage: not('language'),
  isCreating: false,

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

  didInsertElement() {
    scheduleOnce('afterRender', this, function() {
      this.element.querySelector('.textInput').focus();
    });
  },

  actions: {
    submit() {
      this.set('isCreating', true);
      const languageId = this.language;
      const name = this.name;
      const mainColor = this.mainColor;

      this.onCreate({languageId, name, mainColor}).then(() => {
        if (!this.isDestroyed) this.set('isCreating', false);
      });
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
