import Component from '@glimmer/component';
import t from 'ember-intl/helpers/t';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';

interface Args {
  isTextEmptyFilter: boolean;
  isAddedLastSyncFilter: boolean;
  isConflictedFilter: boolean;
  onChangeAdvancedFilterBoolean: (
    key: 'isTextEmpty' | 'isAddedLastSync' | 'isConflicted',
    event: InputEvent
  ) => void;
}

export default class AdvancedFilters extends Component<Args> {
  <template>
    <div class='revision-export-options-advanced-filters'>
      <span class='title'>
        {{t 'components.revision_export_options.advanced_filters_title'}}
      </span>

      <div class='labels'>
        <label class='label'>
          <input
            type='checkbox'
            checked={{@isTextEmptyFilter}}
            {{on 'change' (fn @onChangeAdvancedFilterBoolean 'isTextEmpty')}}
          />
          <span class='label-text'>
            {{t 'components.revision_export_options.advanced_filters.empty'}}
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
              'components.revision_export_options.advanced_filters.added_last_sync'
            }}
          </span>
        </label>

        <label class='label'>
          <input
            type='checkbox'
            checked={{@isConflictedFilter}}
            {{on 'change' (fn @onChangeAdvancedFilterBoolean 'isConflicted')}}
          />
          <span>
            {{t
              'components.revision_export_options.advanced_filters.conflicted'
            }}
          </span>
        </label>
      </div>
    </div>

    <style scoped>
      .revision-export-options-advanced-filters {
        margin: 15px 0 0 0;
        display: flex;
        flex-direction: column;
      }

      .title {
        text-transform: uppercase;
        color: var(--text-color-normal);
        font-size: 11px;
        font-weight: bold;
      }

      .label {
        display: flex;
        align-items: flex-start;
        width: 100%;
        max-width: 250px;
        margin-top: 10px;
        font-size: 12px;
      }
      .label input {
        margin-right: 6px;
      }

      .labels {
        display: flex;
        flex-wrap: wrap;
      }
    </style>
  </template>
}
