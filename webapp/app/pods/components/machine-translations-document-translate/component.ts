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
  fromRevision = this.mappedRevisions[0];

  @tracked
  toRevision = this.mappedRevisions[1] || this.mappedRevisions[0];

  @tracked
  searchedLanguages: Array<{id: string; name: string; slug: string}> = [];

  get sameLanguages() {
    return this.fromRevision.value === this.toRevision.value;
  }

  get isSubmitting() {
    return taskFor(this.submitTask).isRunning;
  }

  get mappedRevisions() {
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
      label: name,
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
        language,
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

  @dropTask
  *submitTask() {
    yield this.renderDocument();

    if (this.sameLanguages) return;

    yield this.args.onTranslate(
      this.fromRevision.value,
      this.toRevision.value,
      this.documentFormat.value
    );
  }

  @action
  async renderDocument() {
    if (!this.revision) return;

    const data = await this.exporter.export({
      revision: this.revision,
      project: this.args.project,
      document: this.args.document,
      documentFormat: this.documentFormat.value,
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
      type: 'charset=utf-8',
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
      value: revision.language.id,
    };
  }

  private mapLanguages(languages: any) {
    return languages.map(this.mapLanguage);
  }

  private mapLanguage({
    id,
    name,
    slug,
  }: {
    id: string;
    name: string;
    slug: string;
  }) {
    const label = htmlSafe(`${name} <em>${slug}</em>`);

    return {label, value: id};
  }
}
