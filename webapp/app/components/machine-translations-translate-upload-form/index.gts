import Component from '@glimmer/component';
import {service} from '@ember/service';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import {htmlSafe} from '@ember/template';
import {dropTask} from 'ember-concurrency';
import GlobalState from 'accent-webapp/services/global-state';
import LanguageSearcher from 'accent-webapp/services/language-searcher';
import FileSaver from 'accent-webapp/services/file-saver';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import {fn, concat} from '@ember/helper';
import willDestroy from '@ember/render-modifiers/modifiers/will-destroy';
import {on} from '@ember/modifier';
import AccSelect from 'accent-webapp/components/acc-select/index';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import AsyncButton from 'accent-webapp/components/async-button/index';
import perform from 'ember-concurrency/helpers/perform';
import t from 'ember-intl/helpers/t';
import FileInput from 'accent-webapp/components/file-input/index';
import {scopedClass} from 'ember-scoped-css';
import HighlightRender from 'accent-webapp/components/highlight-render/index';

interface Revision {
  id: string;
  name: string | null;
  slug: string | null;
  language: {
    id: string;
    name: string;
    slug: string;
  };
}

interface Args {
  revisions: Revision[];
  translatedFileContent: string | null;
  onFileReset: () => Promise<void>;
  onFileChange: (
    file: File,
    fromLanguage: string,
    toLanguage: string,
    documentFormat: string
  ) => Promise<void>;
}

const preventDefault = (event: Event) => event.preventDefault();

export default class MachineTranslationsTranslateUploadForm extends Component<Args> {
  <template>
    <div
      class='content'
      {{didInsert (fn this.deactivateDocumentDrop)}}
      {{willDestroy (fn this.activateDocumentDrop)}}
      {{on 'drop' (fn this.dropFile)}}
    >
      {{#if this.file}}
        <div class='filters'>
          <div class='languages'>
            <AccSelect
              @searchEnabled={{true}}
              @search={{fn this.searchLanguages}}
              @selected={{this.fromLanguage}}
              @options={{this.mappedLanguages}}
              @onchange={{fn this.onSelectFromLanguage}}
            />

            <button
              {{on 'click' (fn this.switchLanguages)}}
              class='button button--iconOnly button-switch'
            >
              {{inlineSvg '/assets/switch.svg' class='button-icon'}}
            </button>

            <AccSelect
              @searchEnabled={{true}}
              @search={{fn this.searchLanguages}}
              @selected={{this.toLanguage}}
              @options={{this.mappedLanguages}}
              @onchange={{fn this.onSelectToLanguage}}
            />
          </div>

          <div class='translate-action'>
            <AccSelect
              @searchEnabled={{false}}
              @selected={{this.documentFormat}}
              @options={{this.mappedDocumentFormats}}
              @onchange={{fn this.onSelectDocumentFormat}}
              class='translate-action-select'
            />

            <AsyncButton
              class='button button--filled translate-action-button'
              @loading={{this.isSubmitting}}
              @onClick={{perform this.submitTask}}
            >
              {{inlineSvg '/assets/language.svg' class='button-icon'}}
              {{t
                'components.machine_translations_translate_upload_form.translate'
              }}
            </AsyncButton>

            <div>
              <FileInput
                name='file-input'
                id='file-input'
                @onChange={{perform this.fileChange}}
                class='fileInput--hidden'
              />
              <label
                for='file-input'
                class='button button--white button--filled fileButton'
              >
                {{inlineSvg
                  '/assets/import.svg'
                  class=(concat 'button-icon' ' ' (scopedClass 'button-icon'))
                }}
                {{t
                  'components.machine_translations_translate_upload_form.new_file'
                }}
              </label>
            </div>
          </div>
        </div>
      {{else}}
        <div class='form'>
          <FileInput
            name='file-input'
            id='file-input'
            @onChange={{perform this.fileChange}}
            class='fileInput'
          />

          <div class='form-content'>
            <div class='form-content-icons'>
              {{inlineSvg
                '/assets/import.svg'
                class=(concat
                  (scopedClass 'form-content-icon')
                  ' '
                  (scopedClass 'form-content-icon--highlight')
                )
              }}
              {{inlineSvg
                '/assets/add.svg'
                class=(concat
                  (scopedClass 'form-content-icon')
                  ' '
                  (scopedClass 'form-content-icon--add')
                )
              }}
              {{inlineSvg
                '/assets/language.svg'
                class=(scopedClass 'form-content-icon')
              }}
            </div>
            <strong>{{t
                'components.machine_translations_translate_upload_form.step_1'
              }}</strong>
            <p class='form-content-text'>
              {{t
                'components.machine_translations_translate_upload_form.step_1_text'
              }}
            </p>
          </div>
        </div>
      {{/if}}

      <div class='preview'>
        <div class='preview-file-content'>
          {{#if this.fileContent}}
            <HighlightRender @content={{this.fileContent}} />
          {{/if}}
        </div>

        <div class='preview-translated-content'>
          {{#if @translatedFileContent}}
            <AsyncButton
              @onClick={{fn this.exportFile}}
              @disabled={{this.exportButtonDisabled}}
              class='button button--filled button-export'
            >
              {{inlineSvg '/assets/export.svg' class='button-icon'}}
              {{t 'components.project_file_operations.export'}}
            </AsyncButton>

            <HighlightRender @content={{@translatedFileContent}} />
          {{/if}}
        </div>
      </div>
    </div>
  </template>
  @service('global-state')
  declare globalState: GlobalState;

  @service('file-saver')
  declare fileSaver: FileSaver;

  @service('language-searcher')
  declare languageSearcher: LanguageSearcher;

  @tracked
  documentFormat = this.mappedDocumentFormats[0];

  @tracked
  file: File | null;

  @tracked
  fileContent: string | ArrayBuffer | null;

  @tracked
  fromLanguage = this.mappedLanguages[0];

  @tracked
  toLanguage = this.mappedLanguages[1] || this.mappedLanguages[0];

  get isSubmitting() {
    return this.submitTask.isRunning;
  }

  get mappedLanguages() {
    return this.mapRevisions(this.args.revisions);
  }

  get mappedDocumentFormats(): Array<{value: string; label: string}> {
    if (!this.globalState.documentFormats) return [];

    return this.globalState.documentFormats.map(({slug, name}) => ({
      value: slug,
      label: name
    }));
  }

  @action
  onSelectDocumentFormat(documentFormat: {label: string; value: string}) {
    this.documentFormat = documentFormat;
  }

  @action
  switchLanguages() {
    const fromLanguage = this.fromLanguage;

    this.fromLanguage = this.toLanguage;
    this.toLanguage = fromLanguage;
  }

  @action
  onSelectFromLanguage(langage: any) {
    this.fromLanguage = langage;
  }

  @action
  onSelectToLanguage(langage: any) {
    this.toLanguage = langage;
  }

  fileChange = dropTask(async (files: File[]) => {
    this.fileContent = null;

    await this.args.onFileReset();

    this.file = files[0];

    const reader = new FileReader();
    reader.onload = (event) =>
      (this.fileContent = event.target?.result || null);
    reader.readAsText(this.file);

    const filename = this.file.name.split('.');
    const fileExtension = filename.pop();
    const formatFromExtension = this.formatFromExtension(fileExtension);
    const mappedDocumentFormat = this.mappedDocumentFormats.find(({value}) => {
      return value === formatFromExtension;
    });

    if (mappedDocumentFormat) this.documentFormat = mappedDocumentFormat;
  });

  @action
  deactivateDocumentDrop() {
    document.addEventListener('dragover', preventDefault);
  }

  @action
  activateDocumentDrop() {
    document.removeEventListener('dragover', preventDefault);
  }

  @action
  async searchLanguages(term: string) {
    const languages = await this.languageSearcher.search({term});

    return this.mapLanguages(languages);
  }

  @action
  dropFile(event: DragEvent) {
    event.preventDefault();
    const file = event.dataTransfer?.files[0];
    this.file = file || null;
  }

  submitTask = dropTask(async () => {
    if (!this.file) return;

    await this.args.onFileChange(
      this.file,
      this.fromLanguage.value,
      this.toLanguage.value,
      this.documentFormat.value
    );
  });

  @action
  exportFile() {
    if (!this.file || !this.args.translatedFileContent) return;

    const blob = new Blob([this.args.translatedFileContent as BlobPart], {
      type: 'charset=utf-8'
    });

    this.fileSaver.saveAs(blob, this.file.name);
  }

  private formatFromExtension(fileExtension?: string) {
    if (!this.globalState.documentFormats) return null;

    const documentFormatItem = this.globalState.documentFormats.find(
      ({extension}) => {
        return extension === fileExtension;
      }
    );

    return documentFormatItem
      ? documentFormatItem.slug
      : this.globalState.documentFormats[0].slug;
  }

  private mapRevisions(revisions: Revision[]) {
    return revisions.map((revision: Revision) => {
      const displayName = revision.name || revision.language.name;
      const label = htmlSafe(
        `${displayName} <em>${revision.slug || revision.language.slug}</em>`
      );

      return {label, value: revision.language.id};
    });
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
