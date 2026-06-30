import Component from '@glimmer/component';
import t from 'ember-intl/helpers/t';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';

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

export default class AdvancedFilters extends Component<Args> {
  <template>
    <div class='conflicts-list-advanced-filters'>
      <span class='title'>
        {{t 'components.conflicts_filters.advanced_filters_title'}}
      </span>

      <div class='labels'>
        <label class='label'>
          <input
            type='checkbox'
            checked={{@isTextEmptyFilter}}
            {{on 'change' (fn @onChangeAdvancedFilterBoolean 'isTextEmpty')}}
          />
          <span class='label-text'>
            {{t 'components.conflicts_filters.advanced_filters.empty'}}
          </span>
        </label>

        <label class='label'>
          <input
            type='checkbox'
            checked={{@isTextNotEmptyFilter}}
            {{on 'change' (fn @onChangeAdvancedFilterBoolean 'isTextNotEmpty')}}
          />
          <span>
            {{t 'components.conflicts_filters.advanced_filters.not_empty'}}
          </span>
        </label>

        <label class='label'>
          <input
            type='checkbox'
            checked={{@isAddedLastSyncFilter}}
            {{on
              'change'
              (fn @onChangeAdvancedFilterBoolean 'isAddedLastSync')
            }}
          />
          <span>
            {{t
              'components.conflicts_filters.advanced_filters.added_last_sync'
            }}
          </span>
        </label>

        <label class='label'>
          <input
            type='checkbox'
            checked={{@isCommentedOnFilter}}
            {{on 'change' (fn @onChangeAdvancedFilterBoolean 'isCommentedOn')}}
          />
          <span>
            {{t 'components.conflicts_filters.advanced_filters.commented_on'}}
          </span>
        </label>

        <label class='label'>
          <input
            type='checkbox'
            checked={{@isTranslatedFilter}}
            {{on 'change' (fn @onChangeAdvancedFilterBoolean 'isTranslated')}}
          />
          <span>
            {{t 'components.conflicts_filters.advanced_filters.translated'}}
          </span>
        </label>
      </div>
    </div>
  </template>
}
