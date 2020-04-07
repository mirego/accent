import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {htmlSafe} from '@ember/string';
import {not} from '@ember/object/computed';
import Component from '@glimmer/component';
import LanguageSearcher from 'accent-webapp/services/language-searcher';
import {tracked} from '@glimmer/tracking';

interface Args {
  permissions: Record<string, true>;
  project: any;
  languages: any;
  onCreate: (language: any) => Promise<void>;
}

export default class CreateForm extends Component<Args> {
  @service('language-searcher')
  languageSearcher: LanguageSearcher;

  @tracked
  languagesCopy = this.args.languages;

  @tracked
  isLoading = false;

  @tracked
  language = this.mappedLanguages[0]?.value;

  @not('language')
  emptyLanguage: boolean;

  get languageValue() {
    return this.mappedLanguages.find(
      ({value}: {value: string}) => value === this.language
    );
  }

  get mappedLanguages() {
    if (!this.languagesCopy) return [];

    return this.mapLanguages(this.languagesCopy);
  }

  @action
  async submit() {
    this.isLoading = true;

    await this.args.onCreate(this.language);

    this.isLoading = false;
  }

  @action
  async searchLanguages(term: string) {
    const languages = await this.languageSearcher.search({term});

    this.languagesCopy = languages;

    return this.mapLanguages(languages);
  }

  @action
  setLanguage({value}: {value: string}) {
    this.language = value;
  }

  private mapLanguages(languages: any) {
    return languages.map(
      ({id, name, slug}: {id: string; name: string; slug: string}) => {
        const label = htmlSafe(`${name} <em>${slug}</em>`);

        return {label, value: id};
      }
    );
  }
}
