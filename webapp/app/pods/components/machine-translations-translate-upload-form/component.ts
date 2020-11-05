import Component from '@glimmer/component';
import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import {htmlSafe} from '@ember/string';
import {dropTask} from 'ember-concurrency-decorators';
import GlobalState from 'accent-webapp/services/global-state';
import LanguageSearcher from 'accent-webapp/services/language-searcher';

interface Args {
  languages: any;
  content: string | null;
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
  fromLanguage = this.mappedLanguages[0];

  @tracked
  toLanguage = this.mappedLanguages[1];

  get mappedLanguages(): Array<{label: string; value: string}> {
    return this.args.languages.map(
      ({id, name}: {id: string; name: string}) => ({
        label: name,
        value: id,
      })
    );
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
  onSelectFromLanguage(langage: {label: string; value: string}) {
    this.fromLanguage = langage;
  }

  @action
  onSelectToLanguage(langage: {label: string; value: string}) {
    this.toLanguage = langage;
  }

  @action
  fileChange(files: File[]) {
    this.file = files[0];
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

  private mapLanguages(languages: any) {
    return languages.map(
      ({id, name, slug}: {id: string; name: string; slug: string}) => {
        const label = htmlSafe(`${name} <em>${slug}</em>`);

        return {label, value: id};
      }
    );
  }
}
