import Component from '@glimmer/component';
import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import {htmlSafe} from '@ember/template';
import {dropTask} from 'ember-concurrency-decorators';
import GlobalState from 'accent-webapp/services/global-state';
import LanguageSearcher from 'accent-webapp/services/language-searcher';
import FileSaver from 'accent-webapp/services/file-saver';
import {taskFor} from 'ember-concurrency-ts';
import Exporter from 'accent-webapp/services/exporter';

interface Project {
  id: string;
}

interface Document {
  id: string;
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
  onFileReset: () => void;
  onFileChange: (
    fromLanguage: string,
    toLanguage: string,
    documentFormat: string
  ) => void;
}

export default class MachineTranslationsTranslateUploadForm extends Component<Args> {
  @service('global-state')
  globalState: GlobalState;

  @service('file-saver')
  fileSaver: FileSaver;

  @service('language-searcher')
  languageSearcher: LanguageSearcher;

  @service('exporter')
  exporter: Exporter;

  @tracked
  documentFormat =
    this.mappedDocumentFormats.find(
      ({value}) => value === this.args.document.format
    ) || this.mappedDocumentFormats[0];

  @tracked
  fileContent: string | ArrayBuffer | null;

  @tracked
  fromLanguage = this.mappedLanguages[0];

  @tracked
  toLanguage = this.mappedLanguages[1] || this.mappedLanguages[0];

  get sameLanguages() {
    return this.fromLanguage.value === this.toLanguage.value;
  }

  get isSubmitting() {
    return taskFor(this.submitTask).isRunning;
  }

  get mappedLanguages() {
    return this.mapRevisions(this.args.revisions);
  }

  get revision() {
    return this.mappedLanguages.find(
      (revision) => revision.id === this.fromLanguage.id
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
  onSelectFromLanguage(langage: any) {
    this.fromLanguage = langage;
  }

  @action
  onSelectToLanguage(langage: any) {
    this.toLanguage = langage;
  }

  @action
  async searchLanguages(term: string) {
    const languages = await this.languageSearcher.search({term});

    return this.mapLanguages(languages);
  }

  @dropTask
  *submitTask() {
    yield this.renderDocument();

    if (this.sameLanguages) return;

    yield this.args.onFileChange(
      this.fromLanguage.value,
      this.toLanguage.value,
      this.documentFormat.value
    );
  }

  @action
  async renderDocument() {
    const data = await this.exporter.export({
      revision: this.revision,
      project: this.args.project,
      document: this.args.document,
      documentFormat: this.documentFormat.value,
    });

    this.fileContent = data;
  }

  @action
  exportFile() {
    if (!this.args.translatedFileContent) return;

    const blob = new Blob([this.args.translatedFileContent as BlobPart], {
      type: 'charset=utf-8',
    });

    this.fileSaver.saveAs(blob, 'doc.txt');
  }

  private mapRevisions(revisions: Revision[]) {
    return revisions.map((revision: Revision) => {
      const displayName = revision.name || revision.language.name;
      const label = htmlSafe(
        `${displayName} <em>${revision.slug || revision.language.slug}</em>`
      );

      return {
        id: revision.id,
        label,
        value: revision.language.id,
        language: revision.language,
      };
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
