import Component from '@glimmer/component';
import {service} from '@ember/service';
import GlobalState from 'accent-webapp/services/global-state';
import t from 'ember-intl/helpers/t';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';

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
  <template>
    <div class='translations-filter-advanced-filters'>
      <span class='title'>
        {{t 'components.translations_filter.advanced_filters_title'}}
      </span>

      <div class='labels'>
        <label class='label'>
          <input
            type='checkbox'
            checked={{@isTextEmptyFilter}}
            {{on 'change' (fn @onChangeAdvancedFilterBoolean 'isTextEmpty')}}
          />
          <span class='label-text'>
            {{t 'components.translations_filter.advanced_filters.empty'}}
          </span>
        </label>

        <label class='label'>
          <input
            type='checkbox'
            checked={{@isTextNotEmptyFilter}}
            {{on 'change' (fn @onChangeAdvancedFilterBoolean 'isTextNotEmpty')}}
          />
          <span>
            {{t 'components.translations_filter.advanced_filters.not_empty'}}
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
              'components.translations_filter.advanced_filters.added_last_sync'
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
            {{t 'components.translations_filter.advanced_filters.commented_on'}}
          </span>
        </label>

        <label class='label'>
          <input
            type='checkbox'
            checked={{@isConflictedFilter}}
            {{on 'change' (fn @onChangeAdvancedFilterBoolean 'isConflicted')}}
          />
          <span>
            {{t 'components.translations_filter.advanced_filters.conflicted'}}
          </span>
        </label>

        {{#if this.showTranslatedFilter}}
          <label class='label'>
            <input
              type='checkbox'
              checked={{@isTranslatedFilter}}
              {{on 'change' (fn @onChangeAdvancedFilterBoolean 'isTranslated')}}
            />
            <span>
              {{t 'components.translations_filter.advanced_filters.translated'}}
            </span>
          </label>
        {{/if}}
      </div>
    </div>
  </template>
  @service('global-state')
  declare globalState: GlobalState;

  get showTranslatedFilter() {
    if (!this.args.revisions) return false;

    const selectedRevision = this.args.revisions.find(
      (revision) => this.globalState.revision === revision.id
    );
    if (!selectedRevision) return false;

    return !selectedRevision.isMaster;
  }
}
