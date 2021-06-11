import Component from '@glimmer/component';
import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import {htmlSafe} from '@ember/string';
import {dropTask} from 'ember-concurrency-decorators';
import GlobalState from 'accent-webapp/services/global-state';
import LanguageSearcher from 'accent-webapp/services/language-searcher';

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
  onFileReset: () => void;
  onFileChange: (
    file: File,
    fromLanguage: string,
    toLanguage: string,
    documentFormat: string
  ) => void;
}

const preventDefault = (event: Event) => event.preventDefault();

export default class MachineTranslationsTranslateUploadForm extends Component<
  Args
> {
  @service('global-state')
  globalState: GlobalState;

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

  get mappedLanguages() {
    return this.mapRevisions(this.args.revisions);
  }

  get mappedDocumentFormats(): Array<{value: string; label: string}> {
    if (!this.globalState.documentFormats) return [];

    return this.globalState.documentFormats.map(({slug, name}) => ({
      value: slug,
      label: name,
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

  @action
  fileChange(files: File[]) {
    this.file = files[0];
    const reader = new FileReader();
    reader.onload = (event) =>
      (this.fileContent = event.target?.result || null);
    reader.readAsText(this.file);
  }

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

  @action
  resetFile() {
    this.file = null;
    this.fileContent = null;
    this.args.onFileReset();
  }

  @dropTask
  *submitTask() {
    if (!this.file) return;

    yield this.args.onFileChange(
      this.file,
      this.fromLanguage.value,
      this.toLanguage.value,
      this.documentFormat.value
    );
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
