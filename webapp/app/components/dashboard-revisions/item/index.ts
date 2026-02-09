import {action} from '@ember/object';
import {readOnly, or} from '@ember/object/computed';
import Component from '@glimmer/component';
import percentage from 'accent-webapp/component-helpers/percentage';
import {tracked} from '@glimmer/tracking';

const LOW_PERCENTAGE = 50;
const HIGH_PERCENTAGE = 90;

interface MainRevision {
  id: string;
  reviewedCount: number;
  translationsCount: number;
}

interface Args {
  project: any;
  revision: any;
  mainRevisions: MainRevision[];
  permissions: Record<string, true>;
  selectedDocument: string | null;
  selectedVersion: string | null;
  onCorrectAllConflicts: (revision: any) => Promise<void>;
  onUncorrectAllConflicts: (revision: any) => Promise<void>;
  onCorrectAllConflictsFromVersion: (revision: any) => Promise<void>;
}

export default class DashboardRevisionsItem extends Component<Args> {
  @readOnly('args.revision.isMaster')
  master: boolean;

  @or(
    'isCorrectAllConflictLoading',
    'isUncorrectAllConflictLoading',
    'isCorrectAllFromVersionLoading'
  )
  isAnyActionsLoading: boolean;

  @tracked
  showActions = false;

  @tracked
  isCorrectAllConflictLoading = false;

  @tracked
  isUncorrectAllConflictLoading = false;

  @tracked
  isCorrectAllFromVersionLoading = false;

  get showCorrectAllAction() {
    return this.correctedKeysPercentage < 100;
  }

  get showUncorrectAllAction() {
    return this.correctedKeysPercentage > 0;
  }

  get mainRevision() {
    return this.args.mainRevisions?.find(
      (r: MainRevision) => r.id === this.args.revision.id
    );
  }

  get mainRevisionHasStringsToReview() {
    if (!this.mainRevision) return false;
    return (
      this.mainRevision.reviewedCount < this.mainRevision.translationsCount
    );
  }

  get mainRevisionReviewedPercentage() {
    if (!this.mainRevision || this.mainRevision.translationsCount === 0)
      return 100;
    return percentage(
      this.mainRevision.reviewedCount,
      this.mainRevision.translationsCount
    );
  }

  get showCorrectAllFromVersionAction() {
    return this.args.selectedVersion && this.mainRevisionHasStringsToReview;
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

  get correctedKeysPercentage() {
    return percentage(
      this.args.revision.translationsCount - this.args.revision.conflictsCount,
      this.args.revision.translationsCount
    );
  }

  get toReviewCount() {
    const {reviewedCount, translationsCount} = this.args.revision;

    return translationsCount - reviewedCount;
  }

  get languageName() {
    return this.args.revision.name || this.args.revision.language.name;
  }

  get rtl() {
    return this.args.revision.rtl || this.args.revision.language.rtl;
  }

  @action
  toggleShowActions() {
    this.showActions = !this.showActions;
  }

  @action
  async correctAllConflicts() {
    this.isCorrectAllConflictLoading = true;

    await this.args.onCorrectAllConflicts(this.args.revision);

    this.onCorrectAllConflictsDone();
  }

  @action
  async uncorrectAllConflicts() {
    this.isUncorrectAllConflictLoading = true;

    await this.args.onUncorrectAllConflicts(this.args.revision);

    this.onUncorrectAllConflictsDone();
  }

  @action
  async correctAllConflictsFromVersion() {
    this.isCorrectAllFromVersionLoading = true;

    await this.args.onCorrectAllConflictsFromVersion(this.args.revision);

    this.onCorrectAllFromVersionDone();
  }

  private onCorrectAllConflictsDone() {
    this.isCorrectAllConflictLoading = false;
  }

  private onUncorrectAllConflictsDone() {
    this.isUncorrectAllConflictLoading = false;
  }

  private onCorrectAllFromVersionDone() {
    this.isCorrectAllFromVersionLoading = false;
  }
}
