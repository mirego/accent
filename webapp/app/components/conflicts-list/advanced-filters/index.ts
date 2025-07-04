import Component from '@glimmer/component';

interface Args {
  revisions: any[];
  isTextEmptyFilter: boolean;
  isTextNotEmptyFilter: boolean;
  isAddedLastSyncFilter: boolean;
  isNotTranslatedFilter: boolean;
  isCommentedOnFilter: boolean;
  onChangeAdvancedFilterBoolean: (
    key:
      | 'isTextEmpty'
      | 'isTextNotEmpty'
      | 'isAddedLastSync'
      | 'isCommentedOn'
      | 'isNotTranslated',
    event: InputEvent
  ) => void;
}

export default class AdvancedFilters extends Component<Args> {}
