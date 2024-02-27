import Component from '@glimmer/component';
import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import {htmlSafe} from '@ember/template';
import {dropTask} from 'ember-concurrency';
import GlobalState from 'accent-webapp/services/global-state';
import LanguageSearcher from 'accent-webapp/services/language-searcher';
import FileSaver from 'accent-webapp/services/file-saver';

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
  @service('global-state')
  globalState: GlobalState;

  @service('file-saver')
  fileSaver: FileSaver;

  @service('language-searcher')
  languageSearcher: LanguageSearcher;

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
