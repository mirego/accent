import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {not} from '@ember/object/computed';
import {htmlSafe} from '@ember/string';
import Component from '@glimmer/component';
import LanguageSearcher from 'accent-webapp/services/language-searcher';
import {tracked} from '@glimmer/tracking';

interface Args {
  error: boolean;
  languages: any;
  onCreate: ({
    languageId,
    name,
    mainColor,
    logo,
  }: {
    languageId: string;
    name: string;
    mainColor: string;
    logo: string;
  }) => Promise<void>;
}

export default class ProjectCreateForm extends Component<Args> {
  @service('language-searcher')
  languageSearcher: LanguageSearcher;

  @tracked
  name: string = '';

  @tracked
  logo: string = '';

  @tracked
  mainColor = '#28cb87';

  @tracked
  languagesCopy = this.args.languages;

  @tracked
  isCreating = false;

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
  logoPicked(logo: string) {
    this.logo = logo;
  }

  @action
  async submit() {
    this.isCreating = true;

    const languageId = this.language;
    const name = this.name;
    const mainColor = this.mainColor;
    const logo = this.logo;

    await this.args.onCreate({languageId, name, mainColor, logo});

    if (!this.isDestroyed) {
      this.isCreating = false;
    }
  }

  @action
  setName(event: Event) {
    const target = event.target as HTMLInputElement;

    this.name = target.value;
  }

  @action
  setMainColor(event: Event) {
    const target = event.target as HTMLInputElement;

    this.mainColor = target.value;
  }

  @action
  setLanguage({value}: {value: string}) {
    this.language = value;
  }

  @action
  async searchLanguages(term: string) {
    const languages = await this.languageSearcher.search({term});

    this.languagesCopy = languages;

    return this.mapLanguages(languages);
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
