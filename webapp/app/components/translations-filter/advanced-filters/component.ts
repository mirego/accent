import Component from '@glimmer/component';
import {inject as service} from '@ember/service';
import GlobalState from 'accent-webapp/services/global-state';

interface Args {
  revisions: any[];
  isTextEmptyFilter: boolean;
  isTextNotEmptyFilter: boolean;
  isAddedLastSyncFilter: boolean;
  isConflictedFilter: boolean;
  isNotTranslatedFilter: boolean;
  isCommentedOnFilter: boolean;
  onChangeAdvancedFilterBoolean: (
    key:
      | 'isTextEmpty'
      | 'isTextNotEmpty'
      | 'isAddedLastSync'
      | 'isCommentedOn'
      | 'isConflicted'
      | 'isNotTranslated',
    event: InputEvent
  ) => void;
}

export default class AdvancedFilters extends Component<Args> {
  @service('global-state')
  globalState: GlobalState;

  get showTranslatedFilter() {
    if (!this.args.revisions) return false;

    const selectedRevision = this.args.revisions.find(
      (revision) => this.globalState.revision === revision.id
    );
    if (!selectedRevision) return false;

    return !selectedRevision.isMaster;
  }
}
