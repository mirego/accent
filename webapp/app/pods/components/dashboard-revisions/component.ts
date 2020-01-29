import {lt, gte} from '@ember/object/computed';
import Component from '@glimmer/component';
import percentage from 'accent-webapp/component-helpers/percentage';

const LOW_PERCENTAGE = 50;
const HIGH_PERCENTAGE = 90;

interface Args {
  document: any;
  project: any;
  activities: any;
  revisions: any;
  permissions: Record<string, true>;
  onCorrectAllConflicts: () => Promise<void>;
  onUncorrectAllConflicts: () => Promise<void>;
}

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
    return this.args.revisions.find((revision: any) => revision.isMaster);
  }

  get slaveRevisions() {
    return this.args.revisions.filter(
      (revision: any) => revision !== this.masterRevision
    );
  }

  get totalStrings() {
    return this.args.revisions.reduce((memo: number, revision: any) => {
      return memo + revision.translationsCount;
    }, 0);
  }

  get totalConflicts() {
    return this.args.revisions.reduce((memo: number, revision: any) => {
      return memo + revision.conflictsCount;
    }, 0);
  }

  get totalReviewed() {
    return this.args.revisions.reduce((memo: number, revision: any) => {
      return memo + (revision.translationsCount - revision.conflictsCount);
    }, 0);
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
