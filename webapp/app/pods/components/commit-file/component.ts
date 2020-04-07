import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {equal} from '@ember/object/computed';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';

const DEFAULT_PROPERTIES = {
  isFileReading: false,
  isFileRead: false,
  isPeeking: false,
  isPeekingDone: false,
  isPeekingError: false,
  isCommiting: false,
  isCommitingDone: false,
  isCommitingError: false,

  file: null,
  fileSource: null,
  documentPath: null,
  documentFormat: 'json',
};

interface Args {
  permissions: Record<string, true>;
  revisions: any;
  documents: any;
  canCommit: boolean;
  commitAction: 'merge' | 'sync';
  peekAction: 'peek_merge' | 'peek_sync';
  commitButtonText: string;
  onFileCancel: () => void;
  onPeek: (options: {
    fileSource: any;
    documentPath: string | null;
    documentFormat: any;
    revision: any;
    mergeType: string;
    syncType: string;
  }) => Promise<void>;
  onCommit: (options: {
    fileSource: any;
    documentPath: string | null;
    documentFormat: any;
    revision: any;
    mergeType: string;
    syncType: string;
  }) => Promise<void>;
}

export default class CommitFile extends Component<Args> {
  @service('intl')
  intl: IntlService;

  @service('global-state')
  globalState: GlobalState;

  @equal('args.commitAction', 'merge')
  isMerge: boolean;

  @equal('args.commitAction', 'sync')
  isSync: boolean;

  mergeTypes = ['smart', 'passive', 'force'];
  syncTypes = ['smart', 'passive'];

  @tracked
  isFileReading = DEFAULT_PROPERTIES.isFileReading;

  @tracked
  isFileRead = DEFAULT_PROPERTIES.isFileRead;

  @tracked
  isPeeking = DEFAULT_PROPERTIES.isPeeking;

  @tracked
  isPeekingDone = DEFAULT_PROPERTIES.isPeekingDone;

  @tracked
  isPeekingError = DEFAULT_PROPERTIES.isPeekingError;

  @tracked
  isCommiting = DEFAULT_PROPERTIES.isCommiting;

  @tracked
  isCommitingDone = DEFAULT_PROPERTIES.isCommitingDone;

  @tracked
  isCommitingError = DEFAULT_PROPERTIES.isCommitingError;

  @tracked
  file: ProgressEvent<FileReader> | null = DEFAULT_PROPERTIES.file;

  @tracked
  fileSource: File | null = DEFAULT_PROPERTIES.fileSource;

  @tracked
  documentPath: string | null = DEFAULT_PROPERTIES.documentPath;

  @tracked
  documentFormat: string | null = DEFAULT_PROPERTIES.documentFormat;

  @tracked
  mergeType = this.mappedMergeTypes[0];

  @tracked
  syncType = this.mappedSyncTypes[0];

  @tracked
  revisionValue =
    this.mappedRevisions.find(({value}) => value === this.revision) ||
    this.mappedRevisions[0];

  @tracked
  revision = this.args.revisions.find((revision: any) => revision.isMaster);

  get mappedMergeTypes() {
    return this.mergeTypes.map((name) => ({
      label: name,
      value: name,
    }));
  }

  get mappedSyncTypes() {
    return this.syncTypes.map((name) => ({
      label: name,
      value: name,
    }));
  }

  get mappedRevisions(): Array<{label: string; value: string}> {
    return this.args.revisions.map(
      ({id, language}: {id: string; language: {name: string}}) => ({
        label: language.name,
        value: id,
      })
    );
  }

  get documentFormatValue() {
    return this.documentFormatOptions.find(({value}) => {
      return value === this.documentFormat;
    });
  }

  get documentFormatOptions(): Array<{value: string; label: string}> {
    if (!this.globalState.documentFormats) return [];

    return this.globalState.documentFormats.map(({slug, name}) => ({
      value: slug,
      label: name,
    }));
  }

  get existingDocumentPath() {
    if (!this.documentPath) return false;
    if (!this.args.documents) return false;

    const path = this.documentPath.replace(/\..+/, '');

    return this.args.documents.find((document: any) => document.path === path);
  }

  @action
  onSelectMergeType(mergeType: {label: string; value: string}) {
    this.mergeType = mergeType;
  }

  @action
  onSelectSyncType(syncType: {label: string; value: string}) {
    this.syncType = syncType;
  }

  @action
  onSelectRevision(revision: {label: string; value: string}) {
    this.revision = this.args.revisions.find(
      ({id}: {id: string}) => id === revision.value
    );

    this.revisionValue = revision;
  }

  @action
  onSelectDocumentFormat(documentFormat: {label: string; value: string}) {
    this.documentFormat = documentFormat.value;
  }

  @action
  async commit() {
    this.onCommiting();

    try {
      await this.args.onCommit({
        fileSource: this.fileSource,
        documentPath: this.documentPath,
        documentFormat: this.documentFormat,
        revision: this.revision,
        mergeType: this.mergeType.value,
        syncType: this.syncType.value,
      });

      this.onCommitingDone();
    } catch (error) {
      this.onCommitingError();
    }
  }

  @action
  async peek() {
    this.onPeeking();

    try {
      await this.args.onPeek({
        fileSource: this.fileSource,
        documentPath: this.documentPath,
        documentFormat: this.documentFormat,
        revision: this.revision,
        mergeType: this.mergeType.value,
        syncType: this.syncType.value,
      });

      this.onPeekingDone();
    } catch (error) {
      this.onPeekingError();
    }
  }

  @action
  fileChange(files: File[]) {
    const fileSource = files[0];
    const filename = fileSource.name.split('.');
    const fileExtension = filename.pop();

    const documentPath = filename.join('.');
    const documentFormat = this.formatFromExtension(fileExtension);
    const isFileReading = true;
    const isFileRead = false;
    const reader = new FileReader();

    this.fileSource = fileSource;
    this.documentPath = documentPath;
    this.isFileReading = isFileReading;
    this.isFileRead = isFileRead;
    this.documentFormat = documentFormat;

    reader.onload = this.fileRead.bind(this);
    reader.readAsText(files[0]);
  }

  @action
  fileCancel() {
    this.args.onFileCancel();

    this.initProperties();
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

  private async fileRead(event: ProgressEvent<FileReader>) {
    this.isFileReading = false;
    this.isFileRead = true;
    this.file = event;

    await this.peek();
  }

  private onCommiting() {
    this.isCommiting = true;
    this.isCommitingDone = false;
    this.isCommitingError = false;
    this.isPeekingError = false;
  }

  private onCommitingDone() {
    this.isCommiting = false;
    this.isCommitingDone = true;
  }

  private onCommitingError() {
    this.isCommiting = false;
    this.isCommitingError = true;
  }

  private onPeeking() {
    this.isPeeking = true;
    this.isPeekingDone = false;
    this.isPeekingError = false;
    this.isCommitingError = false;
  }

  private onPeekingDone() {
    this.isPeeking = false;
    this.isPeekingDone = true;
  }

  private onPeekingError() {
    this.isPeeking = false;
    this.isPeekingError = true;
  }

  private initProperties() {
    this.isFileReading = DEFAULT_PROPERTIES.isFileReading;
    this.isFileRead = DEFAULT_PROPERTIES.isFileRead;
    this.isPeeking = DEFAULT_PROPERTIES.isPeeking;
    this.isPeekingDone = DEFAULT_PROPERTIES.isPeekingDone;
    this.isPeekingError = DEFAULT_PROPERTIES.isPeekingError;
    this.isCommiting = DEFAULT_PROPERTIES.isCommiting;
    this.isCommitingDone = DEFAULT_PROPERTIES.isCommitingDone;
    this.isCommitingError = DEFAULT_PROPERTIES.isCommitingError;
    this.file = DEFAULT_PROPERTIES.file;
    this.fileSource = DEFAULT_PROPERTIES.fileSource;
    this.documentPath = DEFAULT_PROPERTIES.documentPath;
    this.documentFormat = DEFAULT_PROPERTIES.documentFormat;
  }
}
