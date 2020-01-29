import Component from '@glimmer/component';

interface Args {
  isTextEmptyFilter: boolean;
  isTextNotEmptyFilter: boolean;
  isAddedLastSyncFilter: boolean;
  isCommentedOnFilter: boolean;
  onChangeAdvancedFilterBoolean: (
    key: 'isTextEmpty' | 'isTextNotEmpty' | 'isAddedLastSync' | 'isCommentedOn',
    event: InputEvent
  ) => void;
}

export default class AdvancedFilters extends Component<Args> {}
