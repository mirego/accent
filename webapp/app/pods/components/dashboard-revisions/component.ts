import {lt, gte} from '@ember/object/computed';
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
  @lt('reviewedPercentage', LOW_PERCENTAGE)
  lowPercentage: boolean; // Lower than low percentage

  @gte('reviewedPercentage', LOW_PERCENTAGE)
  mediumPercentage: boolean; // higher or equal than low percentage

  @gte('reviewedPercentage', HIGH_PERCENTAGE)
  highPercentage: boolean; // higher or equal than high percentage

  @gte('reviewedPercentage', 100)
  reviewCompleted: boolean;

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
