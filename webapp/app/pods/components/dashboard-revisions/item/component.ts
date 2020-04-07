import {action} from '@ember/object';
import {readOnly, lt, gte, or, gt} from '@ember/object/computed';
import Component from '@glimmer/component';
import percentage from 'accent-webapp/component-helpers/percentage';
import {tracked} from '@glimmer/tracking';

const LOW_PERCENTAGE = 50;
const HIGH_PERCENTAGE = 90;

interface Args {
  project: any;
  revision: any;
  permissions: Record<string, true>;
  onCorrectAllConflicts: (revision: any) => Promise<void>;
  onUncorrectAllConflicts: (revision: any) => Promise<void>;
}

export default class DashboardRevisionsItem extends Component<Args> {
  @readOnly('args.revision.isMaster')
  master: boolean;

  @lt('correctedKeysPercentage', LOW_PERCENTAGE)
  lowPercentage: boolean; // Lower than low percentage

  @gte('correctedKeysPercentage', LOW_PERCENTAGE)
  mediumPercentage: boolean; // higher or equal than low percentage

  @gte('correctedKeysPercentage', HIGH_PERCENTAGE)
  highPercentage: boolean; // higher or equal than high percentage

  @or('isCorrectAllConflictLoading', 'isUncorrectAllConflictLoading')
  isAnyActionsLoading: boolean;

  @lt('correctedKeysPercentage', 100)
  showCorrectAllAction: boolean;

  @gt('correctedKeysPercentage', 0)
  showUncorrectAllAction: boolean;

  @tracked
  showActions = false;

  @tracked
  isCorrectAllConflictLoading = false;

  @tracked
  isUncorrectAllConflictLoading = false;

  get correctedKeysPercentage() {
    return percentage(
      this.args.revision.translationsCount - this.args.revision.conflictsCount,
      this.args.revision.translationsCount
    );
  }

  get reviewsCount() {
    const {conflictsCount, translationsCount} = this.args.revision;

    return translationsCount - conflictsCount;
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

  private onCorrectAllConflictsDone() {
    this.isCorrectAllConflictLoading = false;
  }

  private onUncorrectAllConflictsDone() {
    this.isUncorrectAllConflictLoading = false;
  }
}
