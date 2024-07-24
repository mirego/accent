import Component from '@glimmer/component';
import percentage from 'accent-webapp/component-helpers/percentage';

const LOW_PERCENTAGE = 50;
const HIGH_PERCENTAGE = 90;

interface Revision {
  id: string;
  isMaster: boolean;
  translationsCount: number;
  conflictsCount: number;
}

interface Args {
  document: any;
  project: any;
  activities: any;
  revisions: Revision[];
  permissions: Record<string, true>;
  onCorrectAllConflicts: () => Promise<void>;
  onUncorrectAllConflicts: () => Promise<void>;
}

const calculateTotalRevisions = (
  revisions: Revision[],
  accumulate: (revision: Revision) => number
) => {
  return revisions.reduce((memo, revision) => {
    return memo + accumulate(revision);
  }, 0);
};

export default class DashboardRevisions extends Component<Args> {
  get reviewCompleted() {
    return this.reviewedPercentage >= 100;
  }

  get lowPercentage() {
    return this.reviewedPercentage < LOW_PERCENTAGE;
  }

  get mediumPercentage() {
    return this.reviewedPercentage >= LOW_PERCENTAGE;
  }

  get highPercentage() {
    return this.reviewedPercentage >= HIGH_PERCENTAGE;
  }

  get masterRevision() {
    return this.args.revisions.find((revision: Revision) => revision.isMaster);
  }

  get slaveRevisions() {
    return this.args.revisions.filter(
      (revision: Revision) => revision !== this.masterRevision
    );
  }

  get totalStrings() {
    return calculateTotalRevisions(
      this.args.revisions,
      (revision: Revision) => revision.translationsCount
    );
  }

  get totalConflicts() {
    return calculateTotalRevisions(
      this.args.revisions,
      (revision: Revision) => revision.conflictsCount
    );
  }

  get totalReviewed() {
    return calculateTotalRevisions(
      this.args.revisions,
      (revision: Revision) =>
        revision.translationsCount - revision.conflictsCount
    );
  }

  get reviewedPercentage() {
    return percentage(
      this.totalStrings - this.totalConflicts,
      this.totalStrings
    );
  }

  get conflictedPercentage() {
    return percentage(
      this.totalStrings - this.totalReviewed,
      this.totalStrings
    );
  }
}
