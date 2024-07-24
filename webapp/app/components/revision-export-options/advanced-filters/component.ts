import Component from '@glimmer/component';

interface Args {
  isTextEmptyFilter: boolean;
  isAddedLastSyncFilter: boolean;
  isConflictedFilter: boolean;
  onChangeAdvancedFilterBoolean: (
    key: 'isTextEmpty' | 'isAddedLastSync' | 'isConflicted',
    event: InputEvent
  ) => void;
}

export default class AdvancedFilters extends Component<Args> {}
