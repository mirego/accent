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
import AddSvg from 'accent-webapp/svgs/assets/add.svg';
import ExportSvg from 'accent-webapp/svgs/assets/export.svg';
import ImportSvg from 'accent-webapp/svgs/assets/import.svg';
import LanguageSvg from 'accent-webapp/svgs/assets/language.svg';
import SwitchSvg from 'accent-webapp/svgs/assets/switch.svg';
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
              <SwitchSvg class='button-icon' />
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
              <LanguageSvg class='button-icon' />
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
                <ImportSvg
                  class={{concat 'button-icon' ' ' (scopedClass 'button-icon')}}
                />
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
              <ImportSvg
                class={{concat
                  (scopedClass 'form-content-icon')
                  ' '
                  (scopedClass 'form-content-icon--highlight')
                }}
              />
              <AddSvg
                class={{concat
                  (scopedClass 'form-content-icon')
                  ' '
                  (scopedClass 'form-content-icon--add')
                }}
              />
              <LanguageSvg class={{scopedClass 'form-content-icon'}} />
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
              <ExportSvg class='button-icon' />
              {{t 'components.project_file_operations.export'}}
            </AsyncButton>

            <HighlightRender @content={{@translatedFileContent}} />
          {{/if}}
        </div>
      </div>
    </div>

    <style scoped>
      .content {
        background: var(--content-background);
      }

      .filters {
        padding: 10px;
        background: var(--background-light);
        border-bottom: 1px solid var(--background-light-highlight);
      }
      .filters :global(.ember-power-select-trigger) {
        min-height: 26px;
        border: 1px solid var(--background-light-highlight);
        background: var(--content-background);
        padding: 4px 8px;
        border-radius: var(--border-radius);
      }

      .translate-action,
      .languages {
        display: flex;
        align-items: center;
      }

      .languages {
        margin-bottom: 10px;
      }

      .translate-action-button,
      .translate-action-select {
        margin-right: 10px;
      }

      .button-export {
        position: absolute;
        top: 15px;
        right: 15px;
      }

      .filters-file {
        display: flex;
        align-items: center;
      }

      .form {
        position: relative;
        display: flex;
        justify-content: flex-end;
      }

      .preview {
        display: flex;
      }

      .preview-file-content {
        width: 50%;
        border-right: 1px solid var(--background-light-highlight);
      }

      .preview-translated-content {
        width: 50%;
      }

      .form-content {
        margin: 0 auto;
        padding: 100px 10px;
        max-width: 400px;
        text-align: center;
        font-size: 13px;
      }

      .form-content-icons {
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 20px;
      }

      .form-content-icon {
        width: 40px;
        opacity: 0.6;
        stroke: var(--color-grey);
      }

      .form-content-icon--add {
        width: 20px;
        margin: 0 20px;
      }

      .form-content-text {
        margin-top: 10px;
      }

      .form-content-icon--highlight {
        stroke: var(--color-primary);
      }

      .fileInput {
        opacity: 0;
        overflow: hidden;
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
      }

      .fileInput--hidden {
        display: none;
      }

      :global(.button).button-switch {
        margin: 0 10px;
        opacity: 0.6;
        color: var(--color-black);
      }
      :global(.button).button-switch:hover,
      :global(.button).button-switch:focus {
        opacity: 0.7;
        color: var(--color-black);
      }

      :global(.button).button-resubmit {
        margin-left: 10px;
      }

      .actions {
        position: absolute;
        top: 10px;
        right: 10px;
      }

      .render {
        padding: 15px;
        min-height: 50px;
        border-top: 0;
        box-shadow: inset 0 2px 6px rgba(0, 0, 0, 0.05);
        background: var(--content-background);
        overflow-x: scroll;
        font-family: var(--font-monospace);
        font-size: 11px;
        line-height: 1.7;
      }
    </style>
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
