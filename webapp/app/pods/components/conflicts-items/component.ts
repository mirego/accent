import Component from '@glimmer/component';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';

interface Args {
  referenceRevision: any;
  revision: any;
  fullscreen: boolean;
  permissions: Record<string, true>;
  project: any;
  conflicts: any;
  query: any;
  onCorrect: () => Promise<void>;
  onCorrectAll: () => Promise<void>;
}

export default class ConflictsItems extends Component<Args> {
  @tracked
  isCorrectAllConflictLoading = false;

  get toggledFullscreen() {
    return !this.args.fullscreen;
  }

  @action
  async correctAllConflicts() {
    this.isCorrectAllConflictLoading = true;

    await this.args.onCorrectAll();

    this.isCorrectAllConflictLoading = false;
  }
}
