import {action} from '@ember/object';
import {not} from '@ember/object/computed';
import {inject as service} from '@ember/service';
import Component from '@glimmer/component';
import percentage from 'accent-webapp/component-helpers/percentage';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';

const LOW_PERCENTAGE = 50;
const HIGH_PERCENTAGE = 90;

interface Args {
  permissions: Record<string, true>;
  document: any;
  project: any;
  onDelete: (documentEntity: any) => Promise<void>;
  onUpdate: (documentEntity: any, path: string) => Promise<void>;
}

export default class DocumentsListItem extends Component<Args> {
  @service('global-state')
  globalState: GlobalState;

  @tracked
  renamedDocumentPath = this.args.document.path;

  @not('project.lockedFileOperations')
  canDeleteFile: boolean;

  @tracked
  isEditing = false;

  @tracked
  isDeleting = false;

  @tracked
  isUpdating = false;

  get multipleRevisions() {
    return (
      this.args.project.revisions && this.args.project.revisions.length > 1
    );
  }

  get lowPercentage() {
    return this.correctedKeysPercentage < LOW_PERCENTAGE;
  }

  get mediumPercentage() {
    return this.correctedKeysPercentage >= LOW_PERCENTAGE;
  }

  get highPercentage() {
    return this.correctedKeysPercentage >= HIGH_PERCENTAGE;
  }

  get documentFormatItem() {
    if (!this.globalState.documentFormats) return {};

    return this.globalState.documentFormats.find(({slug}) => {
      return slug === this.args.document.format;
    });
  }

  get empty() {
    return this.args.document.translationsCount === 0;
  }

  get showStats() {
    return !this.empty && !this.isEditing;
  }

  get correctedKeysPercentage() {
    return percentage(
      this.args.document.translationsCount - this.args.document.conflictsCount,
      this.args.document.translationsCount
    );
  }

  get reviewsCount() {
    const {conflictsCount, translationsCount} = this.args.document;

    return translationsCount - conflictsCount;
  }

  @action
  async deleteFile(document: any) {
    this.isDeleting = true;

    await this.args.onDelete(document);

    this.isDeleting = false;
  }

  @action
  toggleEdit() {
    this.isEditing = !this.isEditing;
  }

  @action
  changePath(event: KeyboardEvent) {
    const target = event.target as HTMLInputElement;
    this.renamedDocumentPath = target.value;
  }

  @action
  async updateDocument(event?: Event) {
    event?.preventDefault();

    this.isUpdating = true;

    await this.args.onUpdate(this.args.document, this.renamedDocumentPath);

    this.isUpdating = false;
    this.isEditing = false;
  }
}
