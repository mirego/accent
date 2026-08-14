import Component from '@glimmer/component';
import {service} from '@ember/service';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import {htmlSafe} from '@ember/template';
import {dropTask} from 'ember-concurrency';
import GlobalState from 'accent-webapp/services/global-state';
import LanguageSearcher from 'accent-webapp/services/language-searcher';
import FileSaver from 'accent-webapp/services/file-saver';
import Exporter from 'accent-webapp/services/exporter';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import perform from 'ember-concurrency/helpers/perform';
import AccSelect from 'accent-webapp/components/acc-select/index';
import {fn} from '@ember/helper';
import ChevronRightSvg from 'accent-webapp/svgs/assets/chevron-right.svg';
import ExportSvg from 'accent-webapp/svgs/assets/export.svg';
import LanguageSvg from 'accent-webapp/svgs/assets/language.svg';
import {scopedClass} from 'ember-scoped-css';
import AsyncButton from 'accent-webapp/components/async-button/index';
import t from 'ember-intl/helpers/t';
import HighlightRender from 'accent-webapp/components/highlight-render/index';

interface Project {
  id: string;
}

interface Document {
  id: string;
  path: string;
  format: string;
}

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
  project: Project;
  document: Document;
  translatedFileContent: string | null;
  onTranslate: (
    fromLanguage: string,
    toLanguage: string,
    documentFormat: string
  ) => Promise<void>;
}

export default class MachineTranslationsDocumentTranslate extends Component<Args> {
  <template>
    <div class='content' {{didInsert (perform this.submitTask)}}>
      <div class='filters'>
        <div class='languages'>
          <AccSelect
            @customSelect={{true}}
            @selected={{this.fromRevision}}
            @options={{this.mappedRevisions}}
            @onchange={{fn this.onSelectFromRevision}}
          />

          <div class='arrow'>
            <ChevronRightSvg class={{scopedClass 'arrow-icon'}} />
          </div>

          <AccSelect
            @searchEnabled={{true}}
            @search={{fn this.searchLanguages}}
            @selected={{this.toRevision}}
            @options={{this.mappedRevisions}}
            @onchange={{fn this.onSelectToRevision}}
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
        </div>
      </div>

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
          {{else if this.sameLanguages}}
            <div class='preview-translated-content-empty'>
              {{t
                'components.machine_translations_translate_upload_form.select_target'
              }}
            </div>
          {{/if}}
        </div>
      </div>
    </div>

    <style scoped>
      .content {
        background: var(--content-background);
      }

      .filters {
        display: flex;
        justify-content: space-between;
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

      .translate-action-button,
      .translate-action-select {
        margin-right: 10px;
      }

      .button-export {
        position: absolute;
        top: 10px;
        right: 45px;
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
        opacity: 0.7;
      }

      .preview-translated-content {
        width: 50%;
      }

      .preview-translated-content-empty {
        display: flex;
        width: 100%;
        height: 100%;
        align-items: center;
        justify-content: center;
        padding: 10px;
        color: var(--color-grey);
        font-size: 13px;
        text-align: center;
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

      .arrow {
        margin: 0 10px;
        opacity: 0.6;
        color: var(--color-black);
      }
      .arrow:hover,
      .arrow:focus {
        opacity: 0.7;
        color: var(--color-black);
      }

      .arrow-icon {
        width: 14px;
        height: 14px;
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

  @service('exporter')
  declare exporter: Exporter;

  @tracked
  documentFormat =
    this.mappedDocumentFormats.find(
      ({value}) => value === this.args.document.format
    ) || this.mappedDocumentFormats[0];

  @tracked
  fileContent: string | ArrayBuffer | null;

  @tracked
  fromRevision = this.mappedRevisions[0];

  @tracked
  toRevision = this.mappedRevisions[1] || this.mappedRevisions[0];

  @tracked
  searchedLanguages: Array<{id: string; name: string; slug: string}> = [];

  get sameLanguages() {
    return this.fromRevision.value === this.toRevision.value;
  }

  get isSubmitting() {
    return this.submitTask.isRunning;
  }

  get mappedRevisions() {
    if (!this.args.revisions) return [];
    return this.mapRevisions(this.args.revisions);
  }

  get revision() {
    return this.args.revisions.find(
      (revision) => revision.language.id === this.fromRevision.value
    );
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
  async onSelectFromRevision(select: HTMLSelectElement) {
    const revision = this.args.revisions.find(
      (revision) => revision.language.id === select.value
    );
    this.fromRevision = revision
      ? this.mapRevision(revision)
      : this.fromRevision;

    await this.renderDocument();
  }

  @action
  onSelectToRevision(select: HTMLSelectElement) {
    let revision;

    if (this.searchedLanguages.length) {
      const language = this.searchedLanguages.find(
        (language) => language.id === select.value
      );

      if (!language) return;

      revision = {
        id: language.id,
        name: language.name,
        slug: language.slug,
        language
      };
    } else {
      revision = this.args.revisions.find(
        (revision) => revision.language.id === select.value
      );
    }

    this.toRevision = revision ? this.mapRevision(revision) : this.fromRevision;
  }

  @action
  async searchLanguages(term: string) {
    const languages = await this.languageSearcher.search({term});
    this.searchedLanguages = languages;

    return this.mapLanguages(languages);
  }

  submitTask = dropTask(async () => {
    await this.renderDocument();

    if (this.sameLanguages) return;

    await this.args.onTranslate(
      this.fromRevision.value,
      this.toRevision.value,
      this.documentFormat.value
    );
  });

  @action
  async renderDocument() {
    if (!this.revision) return;

    const data = await this.exporter.export({
      revision: this.revision,
      project: this.args.project,
      document: this.args.document,
      documentFormat: this.documentFormat.value
    });

    this.fileContent = data;
  }

  get documentFormatItem() {
    if (!this.globalState.documentFormats) return {extension: null};

    return this.globalState.documentFormats.find(({slug}) => {
      return slug === this.args.document.format;
    });
  }

  @action
  exportFile() {
    if (!this.args.translatedFileContent) return;

    const blob = new Blob([this.args.translatedFileContent as BlobPart], {
      type: 'charset=utf-8'
    });

    if (this.documentFormatItem?.extension) {
      this.fileSaver.saveAs(
        blob,
        `${this.args.document.path}.${this.documentFormatItem.extension}`
      );
    }
  }

  private mapRevisions(revisions: Revision[]) {
    return revisions.map(this.mapRevision);
  }

  private mapRevision(revision: Revision) {
    const displayName = revision.name || revision.language.name;
    const label = htmlSafe(
      `${displayName} <em>${revision.slug || revision.language.slug}</em>`
    );

    return {
      label,
      value: revision.language.id
    };
  }

  private mapLanguages(languages: any) {
    return languages.map(this.mapLanguage);
  }

  private mapLanguage({
    id,
    name,
    slug
  }: {
    id: string;
    name: string;
    slug: string;
  }) {
    const label = htmlSafe(`${name} <em>${slug}</em>`);

    return {label, value: id};
  }
}
