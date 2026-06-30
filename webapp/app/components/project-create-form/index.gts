import {action} from '@ember/object';
import {service} from '@ember/service';
import {not} from '@ember/object/computed';
import {htmlSafe} from '@ember/template';
import Component from '@glimmer/component';
import LanguageSearcher from 'accent-webapp/services/language-searcher';
import {tracked} from '@glimmer/tracking';
import t from 'ember-intl/helpers/t';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import {fn} from '@ember/helper';
import {on} from '@ember/modifier';
import AccEmojiPicker from 'accent-webapp/components/acc-emoji-picker/index';
import ProjectLogo from 'accent-webapp/components/project-logo/index';
import AccSelect from 'accent-webapp/components/acc-select/index';
import LoadingContent from 'accent-webapp/components/loading-content/index';
import {LinkTo} from '@ember/routing';
import AsyncButton from 'accent-webapp/components/async-button/index';

interface Args {
  error: boolean;
  languages: any;
  onCreate: ({
    languageId,
    name,
    mainColor,
    logo
  }: {
    languageId: string;
    name: string;
    mainColor: string;
    logo: string;
  }) => Promise<void>;
}

export default class ProjectCreateForm extends Component<Args> {
  <template>
    <div class='project-create-form'>
      <h1 class='title'>
        {{t 'components.project_create_form.title'}}
      </h1>

      {{#if @error}}
        <div class='errors'>
          <div class='error'>
            {{t 'components.project_create_form.error'}}
          </div>
        </div>
      {{/if}}

      <div class='formItem'>
        <label class='formItem-label'>
          {{t 'components.project_create_form.name_label'}}
        </label>

        <div class='formItem-fields'>
          <input
            value={{this.name}}
            autofocus
            class='textInput'
            {{didInsert (fn this.autofocus)}}
            {{on 'keyup' (fn this.setName)}}
          />

          <input
            type='color'
            value={{this.mainColor}}
            class='colorInput'
            {{on 'change' (fn this.setMainColor)}}
          />

          <AccEmojiPicker @onPicked={{fn this.logoPicked}} class='logoInput'>
            <ProjectLogo @logo={{this.logo}} />
          </AccEmojiPicker>
        </div>
      </div>

      <div class='formItem'>
        <label class='formItem-label'>
          {{t 'components.project_create_form.language_label'}}
        </label>

        {{#if @languages}}
          <AccSelect
            @searchEnabled={{true}}
            @search={{fn this.searchLanguages}}
            @options={{this.mappedLanguages}}
            @selected={{this.languageValue}}
            @searchPlaceholder={{t
              'components.project_create_form.language_search_placeholder'
            }}
            @onchange={{fn this.setLanguage}}
          />
        {{else}}
          <LoadingContent class='formItem-loading' />
        {{/if}}
      </div>

      <div class='formActions'>
        <LinkTo
          @route='logged-in.projects'
          class='button button--filled button--white cancelButton'
        >
          {{t 'components.project_create_form.cancel_button'}}
        </LinkTo>
        <AsyncButton
          @disabled={{this.emptyLanguage}}
          @loading={{this.isCreating}}
          @onClick={{fn this.submit}}
          class='button button--filled button--green'
        >
          {{t 'components.project_create_form.save_button'}}
        </AsyncButton>
      </div>
    </div>
  </template>
  @service('language-searcher')
  declare languageSearcher: LanguageSearcher;

  @tracked
  name = '';

  @tracked
  logo = '';

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
  logoPicked(selection: string) {
    this.logo = selection;
  }

  @action
  autofocus(input: HTMLInputElement) {
    input.focus();
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
