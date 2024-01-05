import {action} from '@ember/object';
import {readOnly, or} from '@ember/object/computed';
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

  @or('isCorrectAllConflictLoading', 'isUncorrectAllConflictLoading')
  isAnyActionsLoading: boolean;

  @tracked
  showActions = false;

  @tracked
  isCorrectAllConflictLoading = false;

  @tracked
  isUncorrectAllConflictLoading = false;

  get showCorrectAllAction() {
    return this.correctedKeysPercentage < 100;
  }

  get showUncorrectAllAction() {
    return this.correctedKeysPercentage > 0;
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

  get reviewsCount() {
    const {conflictsCount, translationsCount} = this.args.revision;

    return translationsCount - conflictsCount;
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

  private onCorrectAllConflictsDone() {
    this.isCorrectAllConflictLoading = false;
  }

  private onUncorrectAllConflictsDone() {
    this.isUncorrectAllConflictLoading = false;
  }
}
