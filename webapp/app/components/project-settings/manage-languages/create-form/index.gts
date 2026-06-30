import {action} from '@ember/object';
import {service} from '@ember/service';
import {htmlSafe} from '@ember/template';
import {not} from '@ember/object/computed';
import Component from '@glimmer/component';
import LanguageSearcher from 'accent-webapp/services/language-searcher';
import {tracked} from '@glimmer/tracking';
import AccSelect from 'accent-webapp/components/acc-select/index';
import {fn, get} from '@ember/helper';
import t from 'ember-intl/helpers/t';
import {on} from '@ember/modifier';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {scopedClass} from 'ember-scoped-css';
import AsyncButton from 'accent-webapp/components/async-button/index';

interface Args {
  permissions: Record<string, true>;
  project: any;
  languages: any;
  onCreate: (language: any, options: object) => Promise<void>;
}

export default class CreateForm extends Component<Args> {
  <template>
    <div class='form'>
      <AccSelect
        @search={{fn this.searchLanguages}}
        @searchEnabled={{true}}
        @options={{this.mappedLanguages}}
        @selected={{this.languageValue}}
        placeholder={{t
          'components.project_manage_languages_create_form.language_search_placeholder'
        }}
        @searchPlaceholder={{t
          'components.project_manage_languages_create_form.language_search_placeholder'
        }}
        @onchange={{fn this.setLanguage}}
      />

      <div class='options'>
        <div class='option'>
          <label class='optionLabel'>
            <input
              type='checkbox'
              checked={{this.defaultNull}}
              {{on 'change' (fn this.onChangeDefaultNull)}}
            />
            <span class='optionLabelText'>
              {{t
                'components.project_manage_languages_create_form.default_null'
              }}
            </span>
          </label>
        </div>

        {{#if (get @permissions 'machineTranslationsTranslate')}}
          <div class='option'>
            <label class='optionLabel'>
              <input
                type='checkbox'
                checked={{this.machineTranslationsEnabled}}
                {{on 'change' (fn this.onChangeMachineTranslationsEnabled)}}
              />
              <span class='optionLabelText'>
                {{t
                  'components.project_manage_languages_create_form.machine_translations_enabled'
                }}
              </span>

              {{inlineSvg
                'assets/rocket.svg'
                class=(scopedClass 'optionLabel-icon')
              }}
            </label>
          </div>
        {{/if}}
      </div>

      <AsyncButton
        @onClick={{fn this.submit}}
        class='button button--filled'
        @loading={{this.isLoading}}
        @disabled={{this.emptyLanguage}}
      >
        {{t 'components.project_manage_languages_create_form.save_button'}}
      </AsyncButton>
    </div>
  </template>
  @service('language-searcher')
  declare languageSearcher: LanguageSearcher;

  @tracked
  languagesCopy = this.args.languages;

  @tracked
  isLoading = false;

  @tracked
  language = this.mappedLanguages[0]?.value;

  @tracked
  defaultNull = false;

  @tracked
  machineTranslationsEnabled = false;

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
  onChangeDefaultNull() {
    this.defaultNull = !this.defaultNull;
  }

  @action
  onChangeMachineTranslationsEnabled() {
    this.machineTranslationsEnabled = !this.machineTranslationsEnabled;
  }

  @action
  async submit() {
    this.isLoading = true;

    await this.args.onCreate(this.language, {
      machineTranslationsEnabled: this.machineTranslationsEnabled,
      defaultNull: this.defaultNull
    });

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
